defmodule SnowtrackWeb.UserRegistrationControllerTest do
  @moduledoc false
  use SnowtrackWeb.ConnCase, async: true

  import Snowtrack.AccountsFixtures

  describe "LIVE /register" do
    @tag :live
    test "renders the registration page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/register")
      assert html =~ "Register and start monitoring your apps"
      assert html =~ "Log in"
      assert html =~ "<a href=\"/\""
    end

    @tag :live
    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_user(user_fixture()) |> get("/register")
      assert redirected_to(conn) == "/"
    end

    @tag :live
    test "creates account and redirect to the confirm email page", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/register")
      email = unique_user_email()

      view
      |> element("form")
      |> render_submit(%{"user" => %{email: email, password: "valid password"}})

      {path, flash} = assert_redirect(view)
      assert flash["info"] == "You have been registered"
      assert path =~ ~r/\/users\/unconfirmed\?email=.+/
    end

    @tag :live
    test "render errors for invalid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/register")

      html =
        view
        |> element("form")
        |> render_submit(%{"user" => %{email: "invalid email", password: "short"}})

      assert html =~ "must have the @ sign and no spaces"
      assert html =~ "should be at least 6 character"
    end
  end
end
