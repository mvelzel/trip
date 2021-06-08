defmodule TripWeb.ChallengesLive.Index do
  use TripWeb, :live_view

  alias Trip.Challenges

  @impl true
  def mount(_params, session, socket) do
    challenges = Challenges.list_challenges()

    {:ok,
      socket
      |> assign_defaults(session)
      |> assign(challenges: challenges)}
  end
end
