defmodule SnowtrackWeb.Accounts.RequestPasswordResetLive do
  @moduledoc false

  use SnowtrackWeb, :live_view

  alias Snowtrack.Accounts
  alias SnowtrackWeb.Accounts.LoginLive
  alias SnowtrackWeb.Landing.LandingLive

  def render(assigns) do
    ~H"""
    <div class="min-h-full flex flex-col">
      <.navbar />
      <div class="flex grow items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full space-y-8">
          <div>
            <img class="mx-auto h-12 w-auto" src="/images/icon/snowtrack.svg" alt="Snowtrack logo" />
            <h1 class="mt-6 text-center text-3xl font-bold text-white">
              <%= dgettext(
                "accounts",
                "Enter your email and receive your reset password instructions"
              ) %>
            </h1>
          </div>
          <.form let={f} for={:user} phx-submit="submit" class="mt-8 space-y-6">
            <.textfield
              form={f}
              field={:email}
              field_type={:email}
              label={dgettext("accounts", "Email address")}
              placeholder={dgettext("accounts", "Email address")}
            />

            <.submitbtn
              label={dgettext("accounts", "Get my reset password instructions")}
              icon={&ic_lock_open/1}
              label_disable_with={dgettext("accounts", "Sending...")}
            />
          </.form>

          <div class="flex justify-end">
            <%= live_redirect(dgettext("accounts", "No need, I remember my password"),
              to: Routes.live_path(@socket, LoginLive),
              class: "text-sm font-medium text-gray-500 hover:text-gray-400"
            ) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, page_title: dgettext("accounts", "Password forgotten ?"))
    {:ok, socket}
  end

  def handle_event("submit", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        fn token -> Routes.user_reset_password_url(socket, :edit, token) end
      )
    end

    {:noreply,
     socket
     |> put_flash(
       :info,
       dgettext(
         "accounts",
         "If your email is in our system, you will receive instructions to reset your password shortly."
       )
     )
     |> push_redirect(to: Routes.live_path(socket, LoginLive))}
  end
end
