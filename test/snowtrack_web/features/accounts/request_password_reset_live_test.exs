defmodule SnowtrackWeb.RequestPasswordResetTest do
  use SnowtrackWeb.ConnCase, async: true

  alias Snowtrack.Repo
  alias Snowtrack.Accounts
  alias Snowtrack.Accounts.User

  import Snowtrack.AccountsFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, SnowtrackWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(), conn: conn}
  end

  describe "LIVE /users/request_password_reset" do
    @tag :live
    test "renders the reset password request page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/users/request_password_reset")
      assert html =~ "Enter your email"
      assert html =~ "instructions"
      assert html =~ "href=\"/login\""
    end

    @tag :live
    test "sends a new reset password token", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/request_password_reset")

      view |> element("form") |> render_submit(%{"user" => %{"email" => user.email}})

      {path, flash} = assert_redirect(view)
      assert flash["info"] =~ "If your email is in our system"
      assert path == "/login"
      assert_email_sent(to: user.email)

      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "reset_password"
    end

    @tag :live
    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/users/request_password_reset")

      view |> element("form") |> render_submit(%{"user" => %{"email" => "unknown@example.com"}})

      {path, flash} = assert_redirect(view)
      assert flash["info"] =~ "If your email is in our system"
      assert path == "/login"
      assert_no_email_sent()

      assert Repo.all(Accounts.UserToken) == []
    end
  end
end
