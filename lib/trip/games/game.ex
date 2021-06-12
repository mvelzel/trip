defmodule Trip.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :current_round, :integer, default: 0
    field :started, :boolean, default: false
    field :time_started, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:started, :current_round, :time_started])
    |> validate_changeset()
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:started, :current_round])
  end
end
