defmodule SnowtrackWeb.PageControllerTest do
  use SnowtrackWeb.ConnCase

  @tag :live
  test "LIVE /", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Mobile Analytics, the clear way"
  end
end
