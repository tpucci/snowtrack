defmodule SnowtrackWeb.Accounts.ResetPasswordLive do
  use SnowtrackWeb, :live_view

  alias Snowtrack.Accounts
  alias SnowtrackWeb.Accounts.LoginLive

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
                "Create a new password"
              ) %>
            </h1>
          </div>
          <.form let={f} for={@changeset} phx-submit="submit" class="mt-8 space-y-6">
            <div class="space-y-3">
              <.textfield
                form={f}
                field={:password}
                field_type={:password}
                label={dgettext("accounts", "Password")}
                placeholder={dgettext("accounts", "Password")}
              />
              <.textfield
                form={f}
                field={:password_confirmation}
                field_type={:password}
                label={dgettext("accounts", "Confirm your password")}
                placeholder={dgettext("accounts", "Confirm your password")}
              />
            </div>

            <.submitbtn
              label={dgettext("accounts", "Change my password")}
              icon={&ic_lock_open/1}
              label_disable_with={dgettext("accounts", "Changing password...")}
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

  def mount(%{"token" => token}, _session, socket) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      {:ok,
       socket
       |> assign(page_title: dgettext("accounts", "Create a new password"))
       |> assign(:user, user)
       |> assign(:token, token)
       |> assign(changeset: Accounts.change_user_password(user))}
    else
      {:ok,
       socket
       |> put_flash(
         :error,
         dgettext("accounts", "Reset password link is invalid or it has expired.")
       )
       |> push_redirect(to: "/")}
    end
  end

  def handle_event("submit", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Password reset successfully.")
         |> push_redirect(to: Routes.live_path(socket, LoginLive))}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
