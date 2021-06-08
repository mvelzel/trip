defmodule TripWeb.ChallengesLive.Submissions.Index do
  use TripWeb, :live_view

  alias Trip.{Posts, Accounts}

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    posts = Accounts.get_user_posts(socket.assigns.current_user)
    post = Enum.at(posts, 0)
    post_results =
      Posts.list_all_post_results(post.id)
      |> Enum.sort_by(&(&1.inserted_at), {:desc, Date})

    {:ok,
     socket
     |> assign(post_results: post_results)
     |> assign(post: post)
     |> assign(posts: posts)}
  end

  @impl true
  def handle_event("delete-result", %{"index" => index}, socket) do
    post_result =
      socket.assigns.post_results
      |> Enum.at(String.to_integer(index))

    Posts.delete_post_result(post_result)

    post_results =
      Posts.list_all_post_results(socket.assigns.post.id)
      |> Enum.sort_by(&(&1.inserted_at), {:desc, Date})

    {:noreply,
     socket
     |> assign(post_results: post_results)}
  end

  def handle_event("post-selected", %{"value" => id}, socket) do
    post = Posts.get_post!(id)
    post_results =
      Posts.list_all_post_results(post.id)
      |> Enum.sort_by(&(&1.inserted_at), {:desc, Date})

    {:noreply,
     socket
     |> assign(post: post)
     |> assign(post_results: post_results)}
  end
end
