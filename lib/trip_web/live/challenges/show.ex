defmodule TripWeb.ChallengesLive.Show do
  use TripWeb, :live_view

  alias Trip.{Challenges}
  alias Trip.Challenges.Submission
  alias Trip.Accounts

  @impl true
  def mount(%{"challenge" => id}, session, socket) do
    challenge = Challenges.get_challenge!(id)

    socket = assign_defaults(socket, session)
    user = socket.assigns.current_user

    socket =
      if role_allowed(user, [:player, :superuser]) do
        changeset =
          %Submission{}
          |> Submission.changeset(%{
            "group_id" => Accounts.get_user_group(user).id,
            "challenge_id" => id,
            "submission_type" => challenge.submission_type
          })

        assign(socket, changeset: changeset)
      else
        socket
      end

    {:ok,
     socket
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png))
     |> assign(challenge: challenge)}
  end

  def mount(%{"submission" => id}, session, socket) do
    submission = Challenges.get_submission!(id)
    challenge = submission.challenge
    changeset = Submission.approve_changeset(submission, %{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(changeset: changeset)
     |> assign(challenge: challenge)
     |> assign(submission: submission)}
  end

  @impl true
  def handle_event("validate", %{"submission" => submission_params}, socket) do
    changeset =
      %Submission{}
      |> Submission.changeset(submission_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate-approve", %{"submission" => submission_params}, socket) do
    changeset =
      %Submission{}
      |> Submission.approve_changeset(submission_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("create", %{"submission" => submission_params}, socket) do
    case socket.assigns.challenge.submission_type do
      :image ->
        [image] =
          consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
            File.read!(path)
          end)

        {:ok, _} = Challenges.create_submission(submission_params, image)

      :text ->
        {:ok, _} = Challenges.create_submission(submission_params)
    end

    {:noreply, push_redirect(socket, to: Routes.challenges_player_index_path(socket, :index))}
  end

  def handle_event("approve-submission", _params, socket) do
    {:ok, _} =
      Challenges.approve_submission(
        socket.assigns.submission,
        %{"status" => "passed", "score" => to_string(socket.assigns.challenge.max_score)}
      )

    {:noreply, push_redirect(socket, to: Routes.challenges_submissions_index_path(socket, :index))}
  end

  def handle_event("fail-submission", _params, socket) do
    {:ok, _} =
      Challenges.approve_submission(
        socket.assigns.submission,
        %{"status" => "failed", "score" => "0"}
      )

    {:noreply, push_redirect(socket, to: Routes.challenges_submissions_index_path(socket, :index))}
  end

  def handle_event("judge-submission", %{"submission" => submission_params}, socket) do
    status = if submission_params["score"] != "0" do
      "passed"
    else
      "failed"
    end
    {:ok, _} =
      Challenges.approve_submission(
        socket.assigns.submission,
        %{submission_params | "status" => status}
      )

    {:noreply, push_redirect(socket, to: Routes.challenges_submissions_index_path(socket, :index))}
  end
end
