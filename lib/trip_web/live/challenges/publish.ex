defmodule TripWeb.ChallengesLive.Publish do
  use TripWeb, :live_view

  alias Trip.Challenges

  @impl true
  def mount(_params, session, socket) do
    challenges = Challenges.list_challenges()

    challenge = Enum.at(challenges, 0)

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(challenge: challenge)
     |> assign(challenges: challenges)}
  end

  @impl true
  def handle_event("challenge-selected", %{"value" => id}, socket) do
    {:noreply, assign(socket, challenge: Challenges.get_challenge!(id))}
  end

  def handle_event("publish-challenge", _params, socket) do
    {:ok, challenge} = Challenges.publish_challenge(socket.assigns.challenge)

    {:noreply, assign(socket, challenge: challenge)}
  end

  def handle_event("unpublish-challenge", _params, socket) do
    {:ok, challenge} = Challenges.unpublish_challenge(socket.assigns.challenge)

    {:noreply, assign(socket, challenge: challenge)}
  end
end
