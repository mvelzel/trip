defmodule TripWeb.ChallengesLive.Submissions.New do
  use TripWeb, :live_view

  alias Trip.Posts.PostResult
  alias Trip.{Posts, Groups}

  @impl true
  def mount(%{"post" => id}, session, socket) do
    posts = Posts.list_posts()
    post = Posts.get_post!(id)

    locations =
      post.locations
      |> Enum.map(&Map.get(&1, :location))
      |> Enum.uniq_by(&(&1.id))

    changeset =
      %PostResult{post_id: id}
      |> PostResult.changeset(%{}, post.score_type)

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(locations: locations)
     |> assign(selected_location: "")
     |> assign(post: post)
     |> assign(posts: posts)
     |> assign(changeset: changeset)}
  end

  def handle_event("validate", %{"post_result" => post_result_params}, socket) do
    changeset =
      %PostResult{}
      |> PostResult.changeset(post_result_params, socket.assigns.post.score_type)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("create", %{"post_result" => post_result_params}, socket) do
    {:ok, _} =
      Posts.create_post_result(
        post_result_params,
        socket.assigns.post.score_type,
        socket.assigns.post.result_type
      )

    {:noreply, push_redirect(socket, to: Routes.posts_index_path(socket, :index))}
  end

  def handle_event("group-selected", %{"value" => id}, socket) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:group_id, id)
      |> Ecto.Changeset.put_assoc(:group, Groups.get_group!(id))
      |> PostResult.validate_changeset()

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("post-selected", %{"value" => id}, socket) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:post_id, id)
      |> Ecto.Changeset.put_assoc(:post, Posts.get_post!(id))
      |> PostResult.validate_changeset()

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("location-selected", %{"value" => id}, socket) do
    groups = Groups.list_groups(id)

    {:noreply,
     socket
     |> assign(selected_location: id)
     |> assign(groups: groups)}
  end
end
