defmodule SnowtrackWeb.RegisterLive do
  use SnowtrackWeb, :live_view

  alias Snowtrack.Accounts
  alias Snowtrack.Accounts.User
  alias SnowtrackWeb.UserAuth

  def render(assigns) do
    debounce = if assigns.changeset.action, do: nil, else: "blur"

    ~H"""
    <div class="min-h-full flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
      <div class="max-w-md w-full space-y-8">
        <div>
          <img class="mx-auto h-12 w-auto" src="/images/icon/snowtrack.svg" alt="Snowtrack logo" />
          <h1 class="mt-6 text-center text-3xl font-bold text-white">
            <%= dgettext("accounts", "Register and start monitoring your apps") %>
          </h1>
        </div>
        <.form let={f} for={@changeset} phx-change="validate" phx-submit="save" class="mt-8 space-y-6">
          <div class="space-y-3">
            <div>
              <%= label(f, :email, dgettext("accounts", "Email address"), class: "sr-only") %>
              <%= email_input(f, :email,
                required: true,
                phx_debounce: debounce,
                class:
                  "appearance-none relative block w-full px-3 py-2 border border-background-50/[0.1] placeholder-background-500 text-white rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm bg-background-800",
                placeholder: dgettext("accounts", "Email address")
              ) %>
              <%= error_tag(f, :email) %>
            </div>

            <div>
              <%= label(f, :password, dgettext("accounts", "Password"), class: "sr-only") %>
              <%= password_input(f, :password,
                required: true,
                phx_debounce: debounce,
                class:
                  "appearance-none relative block w-full px-3 py-2 border border-background-50/[0.1] placeholder-background-500 text-white rounded-md focus:outline-none focus:ring-primary-500 focus:border-primary-500 focus:z-10 sm:text-sm bg-background-800",
                placeholder: dgettext("accounts", "Password")
              ) %>
              <%= error_tag(f, :password) %>
            </div>
          </div>

          <%= submit class: "group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-primary-600 hover:bg-primary-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500" do %>
            <span class="absolute left-0 inset-y-0 flex items-center pl-3">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5 text-primary-500 group-hover:text-primary-300"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path d="M10 2a5 5 0 00-5 5v2a2 2 0 00-2 2v5a2 2 0 002 2h10a2 2 0 002-2v-5a2 2 0 00-2-2H7V7a3 3 0 015.905-.75 1 1 0 001.937-.5A5.002 5.002 0 0010 2z" />
              </svg>
            </span>
            <%= dgettext("accounts", "Register") %>
          <% end %>
        </.form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    socket = assign(socket, page_title: dgettext("accounts", "Register"))
    socket = assign(socket, changeset: Accounts.change_user_registration(%User{}))
    {:ok, socket}
  end

  def handle_event("validate", %{"user" => params}, socket) do
    changeset =
      %User{}
      |> Accounts.change_user_registration(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &Routes.user_confirmation_url(user, :edit, &1)
          )

        {:noreply,
         socket
         |> put_flash(:info, "user created")
         |> UserAuth.log_in_user(user)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
