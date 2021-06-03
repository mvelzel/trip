defmodule TripWeb.Router do
  use TripWeb, :router
  use Kaffy.Routes #, scope: "/admin", pipe_through: [:some_plug, :authenticate]

  import TripWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {TripWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TripWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", IndexLive, :index

    scope "/locations", LocationsLive do
      live "/", Index, :index

      live "/new", Edit, :new

      live "/edit/:location", Edit, :edit
    end

    scope "/posts", PostsLive do
      live "/", Index, :index

      live "/new", Edit, :new

      live "/edit/:post", Edit, :edit

      scope "/:post/results", Results do
        live "/new", New, :new
      end
    end

    scope "/groups", GroupsLive do
      live "/", Index, :index

      live "/new", Edit, :new

      live "/edit/:group", Edit, :edit
    end

    scope "/users", UsersLive do
      live "/", Index, :index

      live "/new", Edit, :new

      live "/edit/:user", Edit, :edit
    end

    scope "/leaderboards", LeaderboardsLive do
      live "/", Index, :index
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", TripWeb do
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
      live_dashboard "/dashboard", metrics: TripWeb.Telemetry, ecto_repos: [Trip.Repo]
    end
  end

  ## Authentication routes

  scope "/", TripWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated, :put_session_layout]

    get "/users/log_in", UserSessionController, :new
    post "/users/log_in", UserSessionController, :create
  end

  scope "/", TripWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete
  end
end
