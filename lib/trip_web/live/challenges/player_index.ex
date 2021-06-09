defmodule TripWeb.ChallengesLive.PlayerIndex do
  use TripWeb, :live_view

  alias Trip.{Challenges, Accounts}

  @impl true
  def mount(_params, session, socket) do
    challenges = Challenges.list_challenges()

    socket = assign_defaults(socket, session)
    user = socket.assigns.current_user
    group = Accounts.get_user_group(user)

    group_submissions = Challenges.list_submissions_group(group.id)

    {:ok,
     socket
     |> assign(group_submissions: group_submissions)
     |> assign(challenges: challenges)}
  end

  defp get_challenge_status(group_submissions, challenge) do
    challenge_submissions = Enum.filter(group_submissions, &(&1.challenge_id == challenge.id))
    if Enum.count(challenge_submissions) == 0 do
      :unsubmitted
    else
      Enum.at(challenge_submissions, 0).status
    end
  end

  defp get_challenge_submission(group_submissions, challenge) do
    challenge_submissions = Enum.filter(group_submissions, &(&1.challenge_id == challenge.id))
    Enum.at(challenge_submissions, 0)
  end
end
