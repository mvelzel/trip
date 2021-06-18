defmodule Trip.Challenges do
  @moduledoc """
  The Challenges context.
  """

  import Ecto.Query, warn: false
  import TripWeb.Gettext
  alias Trip.Repo

  alias Trip.Groups
  alias Trip.Challenges.{Challenge, Submission}

  @doc """
  Returns the list of challenges.

  ## Examples

      iex> list_challenges()
      [%Challenge{}, ...]

  """
  def list_challenges do
    Repo.all(Challenge)
  end

  def list_submissions(status) do
    Submission
    |> where(status: ^status)
    |> Repo.all()
    |> Repo.preload([:group, :challenge])
  end

  def list_submissions_group(id) do
    Submission
    |> where(group_id: ^id)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets a single challenge.

  Raises `Ecto.NoResultsError` if the Challenge does not exist.

  ## Examples

      iex> get_challenge!(123)
      %Challenge{}

      iex> get_challenge!(456)
      ** (Ecto.NoResultsError)

  """
  def get_challenge!(id), do: Repo.get!(Challenge, id)

  def get_submission!(id),
    do:
      Repo.get!(Submission, id)
      |> Repo.preload([:group, :challenge])

  @doc """
  Creates a challenge.

  ## Examples

      iex> create_challenge(%{field: value})
      {:ok, %Challenge{}}

      iex> create_challenge(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_challenge(attrs) do
    %Challenge{}
    |> Challenge.changeset(attrs)
    |> Repo.insert()
  end

  def create_challenge(attrs, image) do
    %Challenge{}
    |> Challenge.changeset(attrs, image)
    |> Repo.insert()
  end

  def create_submission(attrs) do
    %Submission{}
    |> Submission.changeset(attrs)
    |> Repo.insert()
  end

  def create_submission(attrs, image) do
    %Submission{}
    |> Submission.changeset(attrs, image)
    |> Repo.insert()
  end

  @doc """
  Updates a challenge.

  ## Examples

      iex> update_challenge(challenge, %{field: new_value})
      {:ok, %Challenge{}}

      iex> update_challenge(challenge, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_challenge(%Challenge{} = challenge, attrs) do
    challenge
    |> Challenge.changeset(attrs)
    |> Repo.update()
  end

  def publish_challenge(%Challenge{} = challenge) do
    Trip.Notifications.notify_all_roles(
      %{
        "priority" => "urgent",
        "text" => gettext("A new challenge is temporarily available!"),
        "action" => "/challenges/player"
      },
      [:player, :admin, :judge, :superuser]
    )

    update_challenge(challenge, %{"available" => "true"})
  end

  def unpublish_challenge(%Challenge{} = challenge) do
    update_challenge(challenge, %{"available" => "false"})
  end

  def update_challenge(%Challenge{} = challenge, attrs, image) do
    challenge
    |> Challenge.changeset(attrs, image)
    |> Repo.update()
  end

  def approve_submission(%Submission{} = submission, attrs) do
    group = submission.group
    old_score = submission.score || 0
    group_score = group.score - old_score + String.to_integer(attrs["score"])

    group
    |> Groups.update_group(%{"score" => to_string(group_score)})

    submission
    |> Submission.approve_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a challenge.

  ## Examples

      iex> delete_challenge(challenge)
      {:ok, %Challenge{}}

      iex> delete_challenge(challenge)
      {:error, %Ecto.Changeset{}}

  """
  def delete_challenge(%Challenge{} = challenge) do
    Repo.delete(challenge)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking challenge changes.

  ## Examples

      iex> change_challenge(challenge)
      %Ecto.Changeset{data: %Challenge{}}

  """
  def change_challenge(%Challenge{} = challenge, attrs \\ %{}) do
    Challenge.changeset(challenge, attrs)
  end
end
