defmodule SnowtrackWeb.Accounts.ConfirmLive do
  @moduledoc false

  use SnowtrackWeb, :live_view

  alias Snowtrack.Accounts
  alias SnowtrackWeb.Accounts.LogInLive

  def render(assigns) do
    ~H"""
    <div class="min-h-full flex flex-col">
      <.navbar />
      <div class="flex grow items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full space-y-8">
          <div>
            <img class="mx-auto h-12 w-auto" src="/images/icon/snowtrack.svg" alt="Snowtrack logo" />
            <h1 class="mt-6 text-center text-3xl font-bold text-white">
              <%= dgettext("accounts", "Confirm your email") %>
            </h1>
          </div>

          <.form let={_f} for={:user} phx-submit="confirm" class="mt-8 space-y-6">
            <.submitbtn
              label={dgettext("accounts", "Confirm my account")}
              label_disable_with={dgettext("accounts", "Activating the account...")}
            />
          </.form>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, page_title: dgettext("accounts", "Confirm your email"))
    {:ok, socket}
  end

  def handle_params(%{"token" => token}, _uri, socket) do
    socket = assign(socket, token: token)
    {:noreply, socket}
  end

  # Do not log in the user after confirmation to avoid a
  # leaked token giving the user access to the account.
  def handle_event("confirm", _, socket) do
    case Accounts.confirm_user(socket.assigns.token) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, dgettext("accounts", "User confirmed successfully."))
         |> push_redirect(to: Routes.live_path(socket, LogInLive))}

      :error ->
        # If there is a current user and the account was already confirmed,
        # then odds are that the confirmation link was already visited, either
        # by some automation or by the user themselves, so we redirect without
        # a warning message.
        case socket.assigns do
          %{current_user: %{confirmed_at: confirmed_at}} when not is_nil(confirmed_at) ->
            redirect(socket, to: "/")

          %{} ->
            {
              :noreply,
              socket
              |> put_flash(
                :error,
                dgettext(
                  "accounts",
                  "User confirmation link is invalid or it has expired. Log in again to get another confirmation link."
                )
              )
              |> push_redirect(to: Routes.live_path(socket, LogInLive))
            }
        end
    end
  end
end
