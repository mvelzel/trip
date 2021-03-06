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

    post_states =
      generate_post_states(socket.assigns.current_user, post_locations, socket.assigns.game)

    Phoenix.PubSub.subscribe(Trip.PubSub, "post_claims")

    {:ok,
     socket
     |> assign(locations: locations)
     |> assign(location: location)
     |> assign(selecting: false)
     |> assign(post_locations: post_locations)
     |> assign(post_states: post_states)
     |> assign(post: post)}
  end

  @impl true
  def handle_event("location-selected", %{"value" => id}, socket) do
    location = Locations.get_location!(id)

    post_locations =
      socket.assigns.post.locations
      |> Enum.filter(&(&1.location.id == location.id))

    post_states =
      generate_post_states(socket.assigns.current_user, post_locations, socket.assigns.game)

    {:noreply,
     socket
     |> assign(post_locations: post_locations)
     |> assign(post_states: post_states)
     |> assign(selecting: false)
     |> assign(location: location)}
  end

  def handle_event("show-post", %{"post" => id}, socket) do
    {:noreply, push_redirect(socket, to: Routes.posts_show_path(socket, :show, id))}
  end

  def handle_event("set-selecting", %{"selecting" => selecting}, socket) do
    {:noreply, assign(socket, selecting: String.to_atom(selecting))}
  end

  def handle_event("claim-post", %{"post_location" => id}, socket) do
    current_user = socket.assigns.current_user

    group = Accounts.get_user_group(current_user)

    round = socket.assigns.game.current_round + 2

    Posts.create_post_claim(%{
      "post_location_id" => id,
      "group_id" => group.id,
      "round" => to_string(round)
    })

    {:noreply,
     push_redirect(socket, to: Routes.posts_show_path(socket, :show, socket.assigns.post.id))}
  end

  @impl true
  def handle_info(:post_claims, socket) do
    post_states =
      generate_post_states(
        socket.assigns.current_user,
        socket.assigns.post_locations,
        socket.assigns.game
      )

    {:noreply,
     socket
     |> assign(post_states: post_states)}
  end

  def generate_post_state(current_user, post_location, game) do
    current_claim = Posts.get_post_claims(post_location.id, game.current_round)
    next_claim = Posts.get_post_claims(post_location.id, game.current_round + 1)
    final_claim = Posts.get_post_claims(post_location.id, game.current_round + 2)

    group = Accounts.get_user_group(current_user)

    %{
      current_groups: find_claim_groups(current_claim),
      next_groups: find_claim_groups(next_claim),
      final_groups: find_claim_groups(final_claim),
      can_claim: can_claim?(group, post_location, game)
    }
  end

  def generate_post_states(current_user, post_locations, game) do
    post_locations
    |> Enum.map(&{&1.id, generate_post_state(current_user, &1, game)})
    |> Map.new()
  end

  defp find_claim_groups(claims) do
    if Enum.count(claims) > 0 do
      claims
      |> Enum.map(& &1.group)
    else
      claims
    end
  end

  defp can_claim_any?(current_user, post_locations, game) do
    group = Accounts.get_user_group(current_user)

    post_locations
    |> Enum.map(&can_claim?(group, &1, game))
    |> Enum.any?()
  end

  defp can_claim?(group, post_location, game) do
    if group && post_location.location_id == group.location_id do
      post_claims = Posts.list_all_post_claims_group(group.id)

      current_round = game.current_round

      post_post_claims =
        post_claims
        |> Enum.filter(&(&1.post_location_id == post_location.id))

      most_recent_claim_all =
        Posts.list_all_post_claims(post_location.id)
        |> Enum.sort_by(& &1.round, :desc)

      all_check =
        case post_location.post.result_type do
          :points ->
            if Enum.count(most_recent_claim_all) >= 2 do
              Enum.at(most_recent_claim_all, 0).round != current_round + 2 &&
                Enum.at(most_recent_claim_all, 1).round != current_round + 2
            else
              true
            end

          :high_score ->
            if Enum.count(most_recent_claim_all) >= 1 do
              Enum.at(most_recent_claim_all, 0).round != current_round + 2
            else
              true
            end
        end

      if Enum.count(post_claims) > 0 do
        most_recent =
          post_claims
          |> Enum.sort_by(& &1.round, :desc)
          |> Enum.at(0)

        post_most_recent =
          post_post_claims
          |> Enum.sort_by(& &1.round, :desc)
          |> Enum.at(0)

        all_check &&
          most_recent.round != current_round + 2 &&
          (is_nil(post_most_recent) || post_most_recent.round != current_round) &&
          rem(most_recent.round, 2) == rem(current_round, 2)
      else
        all_check
      end
    else
      false
    end
  end
end
