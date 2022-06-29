defmodule SnowtrackWeb.UserSessionController do
  use SnowtrackWeb, :controller

  alias Snowtrack.Accounts
  alias SnowtrackWeb.UserAuth
  alias SnowtrackWeb.Accounts.UnconfirmedLive

  def create_from_login_token(conn, %{"email" => email, "login_token" => login_token}) do
    if user = Accounts.get_user_by_email_and_login_token(email, login_token) do
      if user.confirmed_at != nil do
        UserAuth.login_user(conn, user)
      else
        conn
        |> put_flash(
          :info,
          dgettext(
            "accounts",
            "Your account has not been confirmed yet. We have sent to %{email} new confirmation instructions.",
            email: user.email
          )
        )
        |> redirect(to: Routes.live_path(conn, UnconfirmedLive, email: user.email))
      end
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      redirect(conn, to: "/login")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
