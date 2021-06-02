defmodule Trip.Posts.ScoreDivision do
  use Ecto.Schema
  import Ecto.Changeset
  alias Trip.Posts.ScoreDivision

  embedded_schema do
    field :points, :integer
  end

  @doc false
  def changeset(%ScoreDivision{} = score_division, attrs) do
    score_division
    |> cast(attrs, [:points])
    |> validate_changeset()
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:points])
  end
end
