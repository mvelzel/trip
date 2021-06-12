defmodule Trip.Posts.PostClaim do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Posts.PostLocation
  alias Trip.Groups.Group

  schema "post_claims" do
    field :round, :integer

    belongs_to :post_location, PostLocation
    belongs_to :group, Group

    timestamps()
  end

  @doc false
  def changeset(post_claim, attrs) do
    post_claim
    |> cast(attrs, [:round, :group_id, :post_location_id])
    |> validate_changeset()
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:round, :group_id, :post_location_id])
  end
end
