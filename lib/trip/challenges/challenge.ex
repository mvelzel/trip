defmodule Trip.Challenges.Challenge do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Challenges.Submission

  @submission_types [:text, :image]

  schema "challenges" do
    field :available, :boolean, default: true
    field :description, :string
    field :max_score, :integer
    field :name, :string
    field :pass_or_fail, :boolean, default: false
    field :submission_type, Ecto.Enum, values: @submission_types

    has_many :submission, Submission

    timestamps()
  end

  @doc false
  def changeset(challenge, attrs) do
    challenge
    |> cast(attrs, [:name, :description, :max_score, :pass_or_fail, :available, :submission_type])
    |> validate_changeset()
    |> cast_assoc(:submission)
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:name, :description, :max_score, :pass_or_fail, :available, :submission_type])
  end

  def submission_types, do: @submission_types
end
