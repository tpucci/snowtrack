defmodule SnowtrackWeb.Components.NavBar do
  use SnowtrackWeb, :component

  import SnowtrackWeb.Components.RedirectBtn

  alias SnowtrackWeb.Accounts.RegisterLive
  alias SnowtrackWeb.Accounts.LoginLive

  def navbar(assigns) do
    ~H"""
    <div class="w-full border-b border-slate-50/[0.1]">
      <div class="py-4 px-4 lg:px-8 flex items-center justify-between max-w-screen-xl mx-auto">
        <a href="/" class="flex items-center pr-3">
          <img src="/images/icon/snowtrack.svg" class="h-8 mr-3" />
          <strong class="text-white">Snowtrack</strong>
        </a>
        <div class="flex gap-2">
          <.redirectbtn label="Register" to={Routes.live_path(SnowtrackWeb.Endpoint, RegisterLive)} />
          <.redirectbtn label="Log in" to={Routes.live_path(SnowtrackWeb.Endpoint, LoginLive)} />
        </div>
      </div>
    </div>
    """
  end
end
