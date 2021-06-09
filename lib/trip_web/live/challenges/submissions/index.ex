defmodule TripWeb.ChallengesLive.Submissions.Index do
  use TripWeb, :live_view

  alias Trip.Challenges
  alias Trip.Challenges.Submission

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    selected_status = "pending"
    submissions = Challenges.list_submissions(selected_status)

    {:ok,
     socket
     |> assign(selected_status: selected_status)
     |> assign(submissions: submissions)}
  end

  @impl true
  def handle_event("status-selected", %{"value" => status}, socket) do
    selected_status = status
    submissions = Challenges.list_submissions(selected_status)

    {:noreply,
     socket
     |> assign(selected_status: selected_status)
     |> assign(submissions: submissions)}
  end
end
