defmodule TripWeb.LeaderboardsLive.Index do
  use TripWeb, :live_view

  alias Trip.{Posts, Groups, Locations}

  @impl true
  def mount(_params, session, socket) do
    posts = Posts.list_posts()
    locations = Locations.list_locations()

    socket = assign_defaults(socket, session)

    user =
      socket.assigns.current_user
      |> Trip.Repo.preload(group: [:location])

    {default_location, location_groups} =
      if Enum.count(locations) > 0 do
        locid =
          case user.role do
            :player ->
              user.group.location.id

            _ ->
              Enum.at(locations, 0).id
          end

        {locid,
         Groups.list_groups(locid)
         |> Enum.sort_by(& &1.score, :desc)}
      else
        {"", []}
      end

    {default_post, post_results} =
      if Enum.count(posts) > 0 do
        defa = Enum.at(posts, 0).id
        {defa, Posts.list_post_results(defa)}
      else
        {"", []}
      end

    groups =
      Groups.list_groups()
      |> Enum.sort_by(& &1.score, :desc)

    {:ok,
     socket
     |> assign(locations: locations)
     |> assign(location_groups: location_groups)
     |> assign(selected_location: "")
     |> assign(default_location: default_location)
     |> assign(default_post: default_post)
     |> assign(post_results: post_results)
     |> assign(groups: groups)
     |> assign(posts: posts)}
  end

  @impl true
  def handle_params(%{"post" => id}, _url, socket) do
    post_results = Posts.list_post_results(id)

    {:noreply,
     socket
     |> assign(selected_location: "")
     |> assign(page: :post)
     |> assign(post_results: post_results)
     |> assign(selected_post: id)}
  end

  def handle_params(%{"location" => id}, _url, socket) do
    groups =
      Groups.list_groups(id)
      |> Enum.sort_by(& &1.score, :desc)

    {:noreply,
     socket
     |> assign(selected_location: id)
     |> assign(selected_post: "")
     |> assign(page: :location)
     |> assign(location_groups: groups)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply,
     socket
     |> assign(selected_post: "")
     |> assign(page: :total)
     |> assign(selected_location: "")}
  end

  @impl true
  def handle_event("location-selected", %{"value" => id}, socket) do
    {:noreply,
     push_patch(socket, to: Routes.leaderboards_index_path(socket, :index, location: id))}
  end

  def handle_event("post-selected", %{"value" => id}, socket) do
    {:noreply, push_patch(socket, to: Routes.leaderboards_index_path(socket, :index, post: id))}
  end

  def handle_event("change-page", %{"page" => page}, socket) do
    {:noreply, assign(socket, page: String.to_atom(page))}
  end
end
