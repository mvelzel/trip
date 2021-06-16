defmodule Trip.Challenges.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Challenges.Challenge
  alias Trip.Groups.Group

  @submission_statuses [:pending, :passed, :failed]

  schema "challenge_submissions" do
    field :image, :binary
    field :video, :string
    field :score, :integer, default: 0
    field :status, Ecto.Enum, values: @submission_statuses, default: :pending
    field :text, :string
    field :submission_type, Ecto.Enum, values: Challenge.submission_types(), virtual: true

    belongs_to :challenge, Challenge
    belongs_to :group, Group

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [
      :status,
      :score,
      :text,
      :image,
      :challenge_id,
      :group_id,
      :submission_type,
      :video
    ])
    |> validate_changeset()
  end

  def changeset(submission, attrs, image) do
    submission
    |> cast(attrs, [:status, :score, :text, :image, :challenge_id, :group_id, :submission_type])
    |> put_change(:image, image)
    |> validate_changeset()
  end

  def approve_changeset(submission, attrs) do
    submission
    |> cast(attrs, [:status, :score])
    |> validate_required([:status, :score])
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:status, :challenge_id, :group_id, :submission_type])
    |> validate_submission()
  end

  defp validate_submission(changeset) do
    submission_type = changeset |> get_field(:submission_type)

    case submission_type do
      :text -> changeset |> validate_required([:text])
      :image -> changeset |> validate_required([])
      :video -> changeset |> validate_required([])
    end
  end

  def submission_statuses, do: @submission_statuses
end
