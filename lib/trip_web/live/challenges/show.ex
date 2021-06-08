defmodule TripWeb.ChallengesLive.Show do
  use TripWeb, :live_view

  alias Trip.{Challenges}

  @impl true
  def mount(%{"challenge" => id}, session, socket) do
    challenge = Challenges.get_challenge!(id)

    socket = assign_defaults(socket, session)

    {:ok,
     socket
     |> assign(challenge: challenge)}
  end
end
