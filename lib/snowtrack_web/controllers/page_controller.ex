defmodule SnowtrackWeb.PageController do
  use SnowtrackWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
