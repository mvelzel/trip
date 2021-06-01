defmodule Trip.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Posts.PostLocation

  schema "posts" do
    field :description, :string
    field :name, :string
    field :number, :integer

    has_many :locations, PostLocation

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:name, :number, :description])
    |> validate_changeset()
    |> cast_assoc(:locations)
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:name, :number, :description])
  end
end
