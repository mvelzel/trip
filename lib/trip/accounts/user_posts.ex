defmodule Trip.Accounts.UserPost do
  use Ecto.Schema
  import Ecto.Changeset

  alias Trip.Accounts.User
  alias Trip.Posts.Post

  schema "user_posts" do
    belongs_to :user, User
    belongs_to :post, Post

    timestamps()
  end

  @doc false
  def changeset(user_posts, attrs) do
    user_posts
    |> cast(attrs, [:user_id, :post_id])
    |> unique_constraint(:post_id, name: :userpostuniq)
    |> assoc_constraint(:user)
  end

  def validate_changeset(changeset) do
    changeset
    |> Map.put(:errors, [])
    |> Map.put(:valid?, true)
    |> validate_required([:post_id])
  end
end
