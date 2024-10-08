defmodule InvoiceAppWeb.Router do
  use InvoiceAppWeb, :router

  import InvoiceAppWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {InvoiceAppWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", InvoiceAppWeb do
    pipe_through :browser
  end

  # Other scopes may use custom stacks.
  # scope "/api", InvoiceAppWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:invoice_app, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: InvoiceAppWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", InvoiceAppWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{InvoiceAppWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      get "/", PageController, :home
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", InvoiceAppWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{InvoiceAppWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email
      live "/users/add_avatar", UserAddAvatarLive
      live "/users/add_address", AddBusinessAddressLive
    end
  end

  scope "/", InvoiceAppWeb do
    pipe_through [
      :browser,
      :require_authenticated_user,
      :require_confirmed_user,
      :require_user_address,
      :require_user_avatar
    ]

    live_session :invoices,
      root_layout: {InvoiceAppWeb.Layouts, :main},
      layout: {InvoiceAppWeb.Layouts, :invoice},
      on_mount: [
        {InvoiceAppWeb.UserAuth, :ensure_authenticated},
        {InvoiceAppWeb.UserAuth, :ensure_confirmed_user},
        {InvoiceAppWeb.UserAuth, :ensure_updated_address},
        {InvoiceAppWeb.UserAuth, :ensure_uploaded_avatar}
      ] do
      live "/settings", SettingsLive

      live "/invoices", InvoiceLive.Index, :index
      live "/invoices/new", InvoiceLive.Index, :new

      live "/invoices/:id", InvoiceLive.Show, :show
      live "/invoices/:id/edit", InvoiceLive.Show, :edit
    end
  end

  scope "/", InvoiceAppWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{InvoiceAppWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new
    end
  end
end
