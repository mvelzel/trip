defmodule TripWeb.ChallengesLive.Edit do
  use TripWeb, :live_view

  alias Trip.Challenges.{Challenge}
  alias Trip.{Challenges}

  @impl true
  def mount(%{"challenge" => id}, session, socket) do
    challenge = Challenges.get_challenge!(id)

    changeset =
      challenge
      |> Challenge.changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png))
     |> assign(challenge: challenge)
     |> assign(changeset: changeset)}
  end

  def mount(_params, session, socket) do
    changeset =
      %Challenge{}
      |> Challenge.changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> allow_upload(:image, accept: ~w(.jpg .jpeg .png))
     |> assign(changeset: changeset)}
  end

  def handle_event(
        "validate",
        %{"challenge" => challenge_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    changeset =
      socket.assigns.challenge
      |> Challenge.changeset(challenge_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", %{"challenge" => challenge_params}, socket) do
    changeset =
      %Challenge{}
      |> Challenge.changeset(challenge_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "create",
        %{"challenge" => challenge_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    if Enum.empty?(socket.assigns.uploads.image.entries) do
      {:ok, _} = Challenges.update_challenge(socket.assigns.challenge, challenge_params)
    else
      [image] =
        consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
          File.read!(path)
        end)

      {:ok, _} = Challenges.update_challenge(socket.assigns.challenge, challenge_params, image)
    end

    {:noreply, push_redirect(socket, to: Routes.challenges_index_path(socket, :index))}
  end

  def handle_event("create", %{"challenge" => challenge_params}, socket) do
    if Enum.empty?(socket.assigns.uploads.image.entries) do
      {:ok, _} = Challenges.create_challenge(challenge_params)
    else
      [image] =
        consume_uploaded_entries(socket, :image, fn %{path: path}, _entry ->
          File.read!(path)
        end)

      {:ok, _} = Challenges.create_challenge(challenge_params, image)
    end

    {:noreply, push_redirect(socket, to: Routes.challenges_index_path(socket, :index))}
  end

  def handle_event("remove-challenge", _params, %{assigns: %{live_action: :edit}} = socket) do
    {:ok, _} = Challenges.delete_challenge(socket.assigns.challenge)

    {:noreply, push_redirect(socket, to: Routes.challenges_index_path(socket, :index))}
  end

  def handle_event("type-selected", %{"value" => type}, socket) do
    changeset =
      socket.assigns.changeset
      |> Ecto.Changeset.put_change(:submission_type, type)
      |> Challenge.validate_changeset()

    {:noreply, assign(socket, changeset: changeset)}
  end
end
