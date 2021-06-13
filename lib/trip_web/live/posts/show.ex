defmodule TripWeb.PostsLive.Show do
  use TripWeb, :live_view

  alias Trip.{Locations, Posts, Accounts}

  @impl true
  def mount(%{"post" => id}, session, socket) do
    locations = Locations.list_locations()
    post = Posts.get_post!(id)

    socket = assign_defaults(socket, session)

    location = Accounts.get_user_location(socket.assigns.current_user)

    post_locations =
      post.locations
      |> Enum.filter(&(&1.location.id == location.id))


    {:ok,
     socket
     |> assign(locations: locations)
     |> assign(location: location)
     |> assign(post_locations: post_locations)
     |> assign(post: post)}
  end

  @impl true
  def handle_event("location-selected", %{"value" => id}, socket) do
    location = Locations.get_location!(id)

    post_locations =
      socket.assigns.post.locations
      |> Enum.filter(&(&1.location.id == location.id))

    {:noreply,
     socket
     |> assign(post_locations: post_locations)
     |> assign(location: location)}
  end

  def handle_event("show-post", %{"post" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.posts_show_path(socket, :show, id))}
  end

  def handle_event("claim-post", _params, socket) do
    current_user = socket.assigns.current_user

    group = Accounts.get_user_group(current_user)

    post_location =
      socket.assigns.post_locations
      |> Enum.find(&(&1.location_id == group.location_id))

    round = socket.assigns.game.current_round + 2

    Posts.create_post_claim(%{
      "post_location_id" => post_location.id,
      "group_id" => group.id,
      "round" => to_string(round)
    })

    {:noreply,
     push_redirect(socket, to: Routes.posts_show_path(socket, :show, socket.assigns.post.id))}
  end

  def generate_post_state(post_location, game) do
    current_claim = Posts.get_post_claim(post_location.id, game.current_round)
    next_claim = Posts.get_post_claim(post_location.id, game.current_round + 1)
    final_claim = Posts.get_post_claim(post_location.id, game.current_round + 2)

    %{
      current_group: find_claim_group(current_claim),
      next_group: find_claim_group(next_claim),
      final_group: find_claim_group(final_claim)
    }
  end

  def generate_post_states(post_locations, game) do
    post_locations
    |> Enum.map(&{&1.id, generate_post_state(&1, game)})
    |> Map.new()
  end

  defp find_claim_group(claim) do
    if claim do
      claim.group
    else
      nil
    end
  end

  defp can_claim?(current_user, post_locations, game) do
    group = Accounts.get_user_group(current_user)

    post_location =
      post_locations
      |> Enum.find(&(&1.location_id == group.location_id))

    post_claims =
      Posts.list_all_post_claims(post_location.id, group.id)

    if Enum.count(post_claims) > 0 do
      most_recent = 
        post_claims
        |> Enum.sort_by(&(&1.round), :desc)
        |> Enum.at(0)


      current_round = game.current_round
      most_recent.round != current_round + 2 &&
        most_recent.round != current_round &&
        rem(most_recent.round, 2) == rem(current_round, 2)
    else
      true
    end
  end
end
