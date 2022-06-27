defmodule SnowtrackWeb.UserSessionController do
  use SnowtrackWeb, :controller

  alias Snowtrack.Accounts
  alias SnowtrackWeb.UserAuth

  def create_from_login_token(conn, %{"email" => email, "login_token" => login_token}) do
    if user = Accounts.get_user_by_email_and_login_token(email, login_token) do
      UserAuth.log_in_user(conn, user)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
