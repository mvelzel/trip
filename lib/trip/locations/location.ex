defmodule Trip.Locations.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :latitude_bottomleft, :float
    field :latitude_topright, :float
    field :longitude_bottomleft, :float
    field :longitude_topright, :float
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :longitude_bottomleft, :latitude_bottomleft, :longitude_topright, :latitude_topright])
    |> validate_required([:name, :longitude_bottomleft, :latitude_bottomleft, :longitude_topright, :latitude_topright])
  end
end
