defmodule SnowtrackWeb.Components.NavBar do
  use Phoenix.Component

  def navbar(assigns) do
    ~H"""
    <div class="w-full border-b border-slate-50/[0.1]">
      <div class="py-4 px-4 lg:px-8 flex items-center max-w-screen-xl mx-auto">
        <a href="/" class="flex items-center pr-3">
          <img src="/images/icon/snowtrack.svg" class="h-8 mr-3" />
          <strong class="text-white">snowtrack</strong>
        </a>
      </div>
    </div>
    """
  end
end
