defmodule SnowtrackWeb.Landing.LandingLive do
  use SnowtrackWeb, :live_view

  def render(assigns) do
    ~H"""
    <.navbar />
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, page_title: dgettext("landing", "Mobile Analytics, the clear way"))
    {:ok, socket}
  end
end
