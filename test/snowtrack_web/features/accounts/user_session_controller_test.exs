defmodule SnowtrackWeb.UserSessionControllerTest do
  use SnowtrackWeb.ConnCase, async: true

  import Snowtrack.AccountsFixtures

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, SnowtrackWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    %{user: user_fixture(), conn: conn}
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> login_user(user) |> delete(Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the user is not logged in", %{conn: conn} do
      conn = delete(conn, Routes.user_session_path(conn, :delete))
      assert redirected_to(conn) == "/"
      refute get_session(conn, :user_token)
      assert get_flash(conn, :info) =~ "Logged out successfully"
    end
  end

  describe "GET /users/login/email/:email/login_token/:login_token" do
    @tag :controller
    test "logs the user in", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/login")

      view
      |> element("form")
      |> render_submit(%{
        "user" => %{"email" => user.email, "password" => valid_user_password()}
      })

      {path, _flash} = assert_redirect(view)

      conn = get(conn, path)

      assert conn.resp_cookies["_snowtrack_web_user_remember_me"]
      assert get_session(conn, :user_token)
    end

    @tag :controller
    test "does not log in an unconfirmed user", %{conn: conn} do
      user = user_fixture(%{confirmed_at: nil})

      {:ok, view, _html} = live(conn, "/login")

      view
      |> element("form")
      |> render_submit(%{
        "user" => %{"email" => user.email, "password" => valid_user_password()}
      })

      {path, _flash} = assert_redirect(view)

      conn = get(conn, path)

      assert redirected_to(conn) =~ "/users/unconfirmed?email=#{URI.encode_www_form(user.email)}"

      assert get_flash(conn, :info) =~ "account has not been confirmed yet"
      assert get_flash(conn, :info) =~ user.email

      assert_email_sent(to: user.email)
    end
  end
end
