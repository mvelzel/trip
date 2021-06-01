defmodule Trip.Posts.PostLocation do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Posts.Post
  alias Trip.Locations.Location

  schema "post_locations" do
    field :latitude, :float
    field :longitude, :float
    field :delete, :boolean, virtual: true

    belongs_to :location, Location
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(post_location, attrs) do
    post_location
    |> cast(attrs, [:latitude, :longitude, :post_id, :location_id, :delete])
    |> assoc_constraint(:post)
    |> validate_changeset()
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:latitude, :longitude, :location_id])
  end
end
