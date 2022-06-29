defmodule SnowtrackWeb.ConfirmLiveTest do
  use SnowtrackWeb.ConnCase, async: true

  alias Snowtrack.Accounts
  alias Snowtrack.Repo
  import Snowtrack.AccountsFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, SnowtrackWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(%{confirmed_at: nil}), conn: conn}
  end

  # TODO: fix test
  describe "GET /users/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.user_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  # TODO: fix test
  describe "POST /users/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, user: user} do
      conn =
        post(conn, Routes.user_confirmation_path(conn, :create), %{
          "user" => %{"email" => user.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Accounts.UserToken, user_id: user.id).context == "confirm"
    end

    test "does not send confirmation token if User is confirmed", %{conn: conn, user: user} do
      Repo.update!(Accounts.User.confirm_changeset(user))

      conn =
        post(conn, Routes.user_confirmation_path(conn, :create), %{
          "user" => %{"email" => user.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Accounts.UserToken, user_id: user.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.user_confirmation_path(conn, :create), %{
          "user" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.UserToken) == []
    end
  end

  describe "LIVE /users/confirm/:token" do
    @tag :live
    test "renders the confirmation page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/users/confirm/some-token")

      assert html =~ "Confirm your email"
      assert html =~ "<a href=\"/\""
    end

    @tag :live
    test "confirms the given token once", %{conn: conn, user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_confirmation_instructions(user, url)
        end)

      # When not logged in and token is valid

      {:ok, view, _html} = live(conn, "/users/confirm/#{token}")

      view |> element("form") |> render_submit()

      {path, flash} = assert_redirect(view)

      assert flash["info"] == "User confirmed successfully."
      assert path == "/login"

      assert Accounts.get_user!(user.id).confirmed_at
      refute get_session(conn, :user_token)
      assert Repo.all(Accounts.UserToken) == []

      # When not logged in and token is expired

      {:ok, view, _html} = live(conn, "/users/confirm/#{token}")
      view |> element("form") |> render_submit()
      {path, flash} = assert_redirect(view)

      assert flash["error"] =~ "User confirmation link is invalid or it has expired"
      assert path == "/login"

      # When logged in

      assert {:error, {:redirect, %{to: "/"}}} =
               build_conn()
               |> login_user(user)
               |> live("/users/confirm/#{token}")
    end

    @tag :live
    test "does not confirm email with invalid token", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/users/confirm/oops")

      view |> element("form") |> render_submit()
      {path, flash} = assert_redirect(view)

      assert flash["error"] =~ "User confirmation link is invalid or it has expired"
      assert path == "/login"
      refute Accounts.get_user!(user.id).confirmed_at
    end
  end
end
