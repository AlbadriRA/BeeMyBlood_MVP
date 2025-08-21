defmodule MatchingWeb.Router do
  use MatchingWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MatchingWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MatchingWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Form, :new
    live "/users/:id/edit", UserLive.Form, :edit
    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit

    live "/traits", TraitLive.Index, :index
    live "/traits/new", TraitLive.Form, :new
    live "/traits/:id/edit", TraitLive.Form, :edit
    live "/traits/:id", TraitLive.Show, :show
    live "/traits/:id/show/edit", TraitLive.Show, :edit

    live "/matching", MatchingLive.Index, :index
    live "/matching/:id", MatchingLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", MatchingWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:matching, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MatchingWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
