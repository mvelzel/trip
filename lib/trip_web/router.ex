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

  pipeline :post_permission do
    plug :allow_roles, [:postleader, :admin, :superuser]
  end

  pipeline :admin_permission do
    plug :allow_roles, [:admin, :superuser]
  end

  pipeline :judge_permission do
    plug :allow_roles, [:admin, :superuser, :judge]
  end

  pipeline :player_permission do
    plug :allow_roles, [:player, :admin, :superuser]
  end

  pipeline :player_judge_permission do
    plug :allow_roles, [:player, :judge, :admin, :superuser]
  end

  scope "/", TripWeb do
    pipe_through [:browser]

    scope "/leaderboards", LeaderboardsLive do
      live "/", Index, :index
    end
  end

  scope "/", TripWeb do
    pipe_through [:browser, :require_authenticated_user, :post_permission]

    scope "/posts", PostsLive do
      live "/:post/results/new", Results.New, :new
    end
  end

  scope "/", TripWeb do
    pipe_through [:browser, :require_authenticated_user, :player_permission]
    
    live "/groups/edit/:group", GroupsLive.Edit, :edit

    live "/challenges/player", ChallengesLive.PlayerIndex, :index
  end

  scope "/", TripWeb do
    pipe_through [:browser, :require_authenticated_user, :judge_permission]

    scope "/challenges", ChallengesLive do
      live "/submissions", Submissions.Index, :index
      
      live "/submissions/:submission", Show, :approve

      live "/", Index, :index
    end
  end

  scope "/", TripWeb do
    pipe_through [:browser, :require_authenticated_user, :admin_permission]

    live "/game", GameLive, :index

    scope "/locations", LocationsLive do
      live "/new", Edit, :new

      live "/", Index, :index

      live "/edit/:location", Edit, :edit
    end

    scope "/posts", PostsLive do
      live "/new", Edit, :new

      live "/claims", Claims.Index, :index

      live "/edit/:post", Edit, :edit

      live "/results", Results.Index, :index
    end

    scope "/challenges", ChallengesLive do
      live "/new", Edit, :new

      live "/edit/:challenge", Edit, :edit

      live "/publish", Publish, :publish
    end

    scope "/users", UsersLive do
      live "/", Index, :index

      live "/new", Edit, :new
    end

    live "groups/new", GroupsLive.Edit, :new

    live "/groups", GroupsLive.Index, :index
  end

  scope "/", TripWeb do
    pipe_through [:browser, :require_authenticated_user, :player_judge_permission]

    live "/challenges/:challenge", ChallengesLive.Show, :show
  end

  scope "/", TripWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/", IndexLive, :index

    scope "/posts", PostsLive do
      live "/", Index, :index
      
      live "/:post", Show, :show
    end

    live "/notifications", NotificationsLive.Index, :index

    live "/users/edit/:user", UsersLive.Edit, :edit

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
