defmodule SnowtrackWeb.Accounts.LogInLive do
  @moduledoc false

  use SnowtrackWeb, :live_view

  alias Snowtrack.Accounts
  alias Snowtrack.Accounts.User
  alias SnowtrackWeb.Accounts.RegisterLive

  def render(assigns) do
    ~H"""
    <div class="min-h-full flex flex-col">
      <.navbar />
      <div class="min-h-full grow flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full space-y-8">
          <div>
            <img class="mx-auto h-12 w-auto" src="/images/icon/snowtrack.svg" alt="Snowtrack logo" />
            <h1 class="mt-6 text-center text-3xl font-bold text-white">
              <%= dgettext("accounts", "Log in") %>
            </h1>
          </div>
          <.form let={f} for={:user} phx-submit="login" class="mt-8 space-y-6">
            <div class="space-y-3">
              <.textfield
                form={f}
                field={:email}
                field_type={:email}
                label={dgettext("accounts", "Email address")}
                placeholder={dgettext("accounts", "Email address")}
              />

              <.textfield
                form={f}
                field={:password}
                field_type={:password}
                label={dgettext("accounts", "Password")}
                placeholder={dgettext("accounts", "Password")}
              />
            </div>

            <.submitbtn
              label={dgettext("accounts", "Log in")}
              icon={&ic_lock_open/1}
              label_disable_with={dgettext("accounts", "Logging in...")}
            />
          </.form>

          <div class="flex justify-between flex-col sm:flex-row space-y-3 sm:space-y-0">
            <%= live_redirect(dgettext("accounts", "Don't have an account ? Register here"),
              to: Routes.live_path(@socket, RegisterLive),
              class: "text-sm font-medium text-primary-600 hover:text-primary-500"
            ) %>

            <%= live_redirect(dgettext("accounts", "I forgot my password"),
              to: Routes.live_path(@socket, RegisterLive),
              # TODO: Redirect to forgot password
              class: "text-sm font-medium text-gray-500 hover:text-gray-400"
            ) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, page_title: dgettext("accounts", "Log in"))
    {:ok, socket}
  end

  def handle_event("login", %{"user" => user_params}, socket) do
    %{"email" => email, "password" => password} = user_params

    if user = Accounts.get_user_by_email_and_password(email, password) do
      login_token = User.generate_login_token()

      Accounts.update_login_token(user, %{login_token: login_token})

      {:noreply,
       socket
       |> redirect(
         to: Routes.user_session_path(socket, :create_from_login_token, user.email, login_token)
       )}
    else
      {:noreply,
       socket
       |> put_flash(:error, dgettext("accounts", "Invalid email or password"))}
    end
  end
end
