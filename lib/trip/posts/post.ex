defmodule Trip.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Posts.PostLocation
  alias Trip.Posts.ScoreDivision

  @result_types [:points, :high_score]
  @score_types [:points, :time]

  @derive {Jason.Encoder,
           only: [:description, :name, :number, :result_type, :score_type, :id, :score_divisions]}
  schema "posts" do
    field :description, :string
    field :name, :string
    field :number, :integer
    field :result_type, Ecto.Enum, values: @result_types
    field :score_type, Ecto.Enum, values: @score_types, default: :points

    has_many :locations, PostLocation

    embeds_many :score_divisions, ScoreDivision, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:name, :number, :description, :result_type, :score_type])
    |> validate_changeset()
    |> cast_assoc(:locations)
    |> cast_embed(:score_divisions)
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:name, :number, :description, :result_type, :score_type])
  end

  def result_types, do: @result_types
  def score_types, do: @score_types
end
