defmodule SnowtrackWeb.Accounts.UnconfirmedLive do
  @moduledoc false

  use SnowtrackWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-full flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8">
        <div>
          <img class="mx-auto h-12 w-auto" src="/images/icon/snowtrack.svg" alt="Snowtrack logo" />
          <h1 class="mt-6 text-center text-3xl font-bold text-white">
            <%= dgettext("accounts", "Confirm your email") %>
          </h1>
        </div>
        <p>
          <%= dgettext(
            "accounts",
            "We successfully created your account ! Check your mailbox (%{email}) and visit the link we sent you to confirm your email address.",
            email: @email
          ) %>
        </p>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, page_title: dgettext("accounts", "Confirm your email"))
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket = assign(socket, email: params["email"])
    {:noreply, socket}
  end
end
