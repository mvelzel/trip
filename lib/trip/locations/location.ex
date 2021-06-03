defmodule Trip.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:lat0, :lon0, :lat1, :lon1, :name, :id]}
  schema "locations" do
    field :lat0, :float
    field :lon0, :float
    field :lat1, :float
    field :lon1, :float
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :lat0, :lon0, :lat1, :lon1])
    |> validate_changeset()
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:name, :lat0, :lon0, :lat1, :lon1])
  end
end
