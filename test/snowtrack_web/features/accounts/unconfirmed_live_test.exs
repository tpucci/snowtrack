defmodule SnowtrackWeb.UnconfirmedLiveTest do
  @moduledoc false
  use SnowtrackWeb.ConnCase, async: true

  describe "LIVE /users/unconfirmed" do
    @tag :live
    test "renders the unconfirmed page", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/users/unconfirmed?email=john@doe.com")
      assert html =~ "john@doe.com"
      assert html =~ "Confirm your email"
      assert html =~ "<a href=\"/\""
    end
  end
end
