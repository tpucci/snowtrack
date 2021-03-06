defmodule SnowtrackWeb.Router do
  use SnowtrackWeb, :router

  import SnowtrackWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SnowtrackWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Other scopes may use custom stacks.
  # scope "/api", SnowtrackWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SnowtrackWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # Landing routes

  scope "/", SnowtrackWeb do
    pipe_through :browser

    live "/", Landing.LandingLive
  end

  ## Authentication routes

  scope "/", SnowtrackWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :unregistered do
      live "/login", Accounts.LoginLive
      live "/register", Accounts.RegisterLive
      live "/users/confirm/:token", Accounts.ConfirmLive
      live "/users/request_password_reset", Accounts.RequestPasswordResetLive
      live "/users/reset_password/:token", Accounts.ResetPasswordLive
      live "/users/unconfirmed", Accounts.UnconfirmedLive
    end

    get "/users/login/email/:email/login_token/:login_token",
        Accounts.UserSessionController,
        :create_from_login_token
  end

  scope "/", SnowtrackWeb do
    pipe_through [:browser, :require_authenticated_user]

    get "/users/settings", UserSettingsController, :edit
    put "/users/settings", UserSettingsController, :update
    get "/users/settings/confirm_email/:token", UserSettingsController, :confirm_email
  end

  scope "/", SnowtrackWeb do
    pipe_through [:browser]

    delete "/users/log_out", Accounts.UserSessionController, :delete
  end
end
