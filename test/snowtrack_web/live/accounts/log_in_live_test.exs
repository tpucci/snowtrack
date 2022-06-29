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

  describe "LIVE /login" do
    @tag :live
    test "renders log in page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/login")

      assert html =~ "Log in"
      assert html =~ "Register here</a>"
      assert html =~ "I forgot my password</a>"
      assert html =~ "<a href=\"/\""
    end

    @tag :live
    test "redirects if already logged in", %{user: user} do
      assert {:error, {:redirect, %{to: "/"}}} =
               build_conn()
               |> log_in_user(user)
               |> live("/login")
    end

    @tag :live
    test "logs the user in", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/login")

      view
      |> element("form")
      |> render_submit(%{
        "user" => %{"email" => user.email, "password" => valid_user_password()}
      })

      {path, flash} = assert_redirect(view)

      refute flash["error"]
      assert path =~ "/users/log_in/email/#{user.email |> URI.encode_www_form()}/login_token/"
    end

    @tag :live
    test "emits error message with invalid credentials", %{conn: conn, user: user} do
      {:ok, view, _html} = live(conn, "/login")

      html =
        view
        |> element("form")
        |> render_submit(%{
          "user" => %{"email" => user.email, "password" => "oops"}
        })

      assert html =~ "Log in"
      assert html =~ "Invalid email or password"
    end
  end

  describe "DELETE /users/log_out" do
    test "logs the user out", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user) |> delete(Routes.user_session_path(conn, :delete))
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

  @tag :integration
  describe "GET /users/log_in/email/:email/login_token/:login_token" do
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
  end
end
