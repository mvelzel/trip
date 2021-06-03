defmodule Trip.Posts.PostResult do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Groups.Group
  alias Trip.Posts.Post

  @derive {Jason.Encoder, only: [:score, :group, :post, :id]}
  schema "post_results" do
    field :score, :integer
    field :minutes, :integer, virtual: true
    field :seconds, :integer, virtual: true

    belongs_to :group, Group
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(post_result, attrs, :points) do
    post_result
    |> cast(attrs, [:score, :post_id, :group_id, :minutes, :seconds])
    |> validate_changeset()
  end

  def changeset(post_result, attrs, :time) do
    post_result
    |> cast(attrs, [:score, :post_id, :group_id, :minutes, :seconds])
    |> time_to_score()
    |> validate_changeset()
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:score, :post_id, :group_id])
  end

  defp time_to_score(changeset) do
    minutes = changeset |> get_field(:minutes)
    seconds = changeset |> get_field(:seconds)
    if is_nil(minutes) and is_nil(seconds) do
      changeset
    else
      minutes = minutes || 0
      seconds = seconds || 0
      changeset |> put_change(:score, minutes * 60 + seconds)
    end
  end
end
