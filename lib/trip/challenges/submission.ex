defmodule Trip.Challenges.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Challenges.Challenge
  alias Trip.Groups.Group

  @submission_statuses [:pending, :passed, :failed]

  schema "challenge_submissions" do
    field :image, :binary
    field :score, :integer
    field :status, Ecto.Enum, values: @submission_statuses
    field :text, :string

    belongs_to :challenge, Challenge
    belongs_to :group, Group

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:status, :score, :text, :image, :challenge_id, :group_id])
    |> validate_changeset()
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:status, :score, :text, :image, :challenge_id, :group_id])
  end
end
