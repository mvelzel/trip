defmodule Trip.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Posts.PostLocation
  alias Trip.Posts.ScoreDivision

  @score_types [:points, :high_score]

  schema "posts" do
    field :description, :string
    field :name, :string
    field :number, :integer
    field :score_type, Ecto.Enum, values: @score_types

    has_many :locations, PostLocation

    embeds_many :score_divisions, ScoreDivision

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:name, :number, :description, :score_type])
    |> validate_changeset()
    |> cast_assoc(:locations)
    |> cast_embed(:score_divisions)
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:name, :number, :description, :score_type])
  end

  def score_types, do: @score_types
end
