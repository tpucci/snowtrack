defmodule SnowtrackWeb.ResetPasswordLiveTest do
  use SnowtrackWeb.ConnCase, async: true

  alias Snowtrack.Accounts
  alias Snowtrack.Repo
  import Snowtrack.AccountsFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, SnowtrackWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(), conn: conn}
  end

  describe "LIVE /users/reset_password/:token" do
    setup %{user: user} do
      token =
        extract_user_token(fn url ->
          Accounts.deliver_user_reset_password_instructions(user, url)
        end)

      %{token: token}
    end

    @tag :live
    test "renders reset password", %{conn: conn, token: token} do
      {:ok, _view, html} = live(conn, "/users/reset_password/#{token}")
      assert html =~ "Create a new password"
      assert html =~ "href=\"/login\""
    end

    @tag :live
    test "does not render reset password with invalid token", %{conn: conn} do
      {:error, {:live_redirect, %{flash: %{"error" => error}, to: to}}} =
        live(conn, "/users/reset_password/oops")

      assert error =~ "Reset password link is invalid or it has expired"
      assert to == "/"
    end

    @tag :live
    test "resets password once", %{conn: conn, user: user, token: token} do
      {:ok, view, _html} = live(conn, "/users/reset_password/#{token}")

      view
      |> element("form")
      |> render_submit(%{
        "user" => %{
          "password" => "new valid password",
          "password_confirmation" => "new valid password"
        }
      })

      {path, flash} = assert_redirect(view)
      assert flash["info"] =~ "Password reset successfully"
      assert path == "/login"

      refute get_session(conn, :user_token)
      assert Accounts.get_user_by_email_and_password(user.email, "new valid password")
    end

    @tag :live
    test "does not reset password on invalid data", %{conn: conn, token: token} do
      {:ok, view, _html} = live(conn, "/users/reset_password/#{token}")

      html =
        view
        |> element("form")
        |> render_submit(%{
          "user" => %{
            "password" => "short",
            "password_confirmation" => "oops"
          }
        })

      assert html =~ "should be at least 6 character(s)"
      assert html =~ "does not match password"
    end
  end
end
