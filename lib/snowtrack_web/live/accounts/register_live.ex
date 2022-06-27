defmodule SnowtrackWeb.Accounts.RegisterLive do
  @moduledoc false

  use SnowtrackWeb, :live_view

  alias Snowtrack.Accounts
  alias Snowtrack.Accounts.User
  alias SnowtrackWeb.Accounts.LogInLive
  alias SnowtrackWeb.Accounts.ConfirmLive
  alias SnowtrackWeb.Accounts.UnconfirmedLive

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
            <.textfield
              form={f}
              field={:email}
              field_type={:email}
              label={dgettext("accounts", "Email address")}
              placeholder={dgettext("accounts", "Email address")}
              debounce={debounce}
            />

            <.textfield
              form={f}
              field={:password}
              field_type={:password}
              label={dgettext("accounts", "Password")}
              placeholder={dgettext("accounts", "Password")}
              debounce={debounce}
            />
          </div>

          <.submitbtn
            label={dgettext("accounts", "Register")}
            icon={&ic_lock_open/1}
            label_disable_with={dgettext("accounts", "Registering...")}
          />
        </.form>

        <div>
          <%= live_redirect(dgettext("accounts", "Already have an account ? Log in here"),
            to: Routes.live_path(@socket, LogInLive),
            class: "text-sm font-medium text-primary-600 hover:text-primary-500"
          ) %>
        </div>
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

  def handle_event("save", changeset, socket) do
    case Accounts.register_user(changeset["user"]) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            fn params -> Routes.live_path(socket, ConfirmLive, params) end
          )

        {:noreply,
         socket
         |> put_flash(:info, dgettext("accounts", "You have been registered"))
         |> push_redirect(to: Routes.live_path(socket, UnconfirmedLive, email: user.email))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
