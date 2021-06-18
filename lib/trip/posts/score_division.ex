defmodule Trip.Posts.ScoreDivision do
  use Ecto.Schema
  import Ecto.Changeset
  import Trip.ChangesetHelpers
  alias Trip.Posts.ScoreDivision

  @derive Jason.Encoder
  embedded_schema do
    field :points, :integer
    field :delete, :boolean, virtual: true
  end

  @doc false
  def changeset(%ScoreDivision{} = score_division, attrs) do
    score_division
    |> cast(attrs, [:points, :delete])
    |> validate_changeset()
    |> maybe_mark_for_deletion()
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:points])
  end
end
