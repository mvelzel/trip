defmodule TripWeb.PostsLive.Index do
  use TripWeb, :live_view

  alias Trip.Posts

  @impl true
  def mount(_params, session, socket) do
    posts = Posts.list_posts()

    {:ok,
      socket
      |> assign_defaults(session)
      |> assign(posts: posts)}
  end
end
