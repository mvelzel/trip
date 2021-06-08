defmodule TripWeb.PostsLive.Index do
  use TripWeb, :live_view
  import TripWeb.UserAuth

  alias Trip.Accounts

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    posts = Accounts.get_user_posts(socket.assigns.current_user)

    {:ok,
      socket
      |> assign(posts: posts)}
  end
end
