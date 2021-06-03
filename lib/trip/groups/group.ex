defmodule Trip.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Locations.Location

  @derive {Jason.Encoder, only: [:girls_only, :name, :number, :score, :id]}
  schema "groups" do
    field :girls_only, :boolean, default: false
    field :name, :string
    field :number, :integer
    field :score, :integer, default: 0

    belongs_to :location, Location, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :number, :girls_only, :location_id, :score])
    |> validate_changeset()
    |> cast_assoc(:location)
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:name, :number, :girls_only, :location_id])
  end
end
