defmodule Trip.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Trip.Repo

  alias Trip.Groups
  alias Trip.Posts.{Post, PostResult, PostLocation}

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Post
    |> order_by(:number)
    |> Repo.all()
  end

  def list_posts_locations(location_id) do
    PostLocation
    |> where(location_id: ^location_id)
    |> Repo.all()
    |> Repo.preload(:post)
  end

  def list_post_results(post_id) do
    type = get_post!(post_id).score_type

    filtered_posts =
      from r in PostResult,
        where: r.post_id == ^post_id

    query = case type do
      :points ->
        (from r in PostResult,
          where: r.post_id == ^post_id,
          left_join: p in ^filtered_posts,
          on: r.group_id == p.group_id and r.score < p.score,
          where: is_nil(p.id),
          select: r
        )
        |> order_by([desc: :score])
      :time ->
        (from r in PostResult,
          where: r.post_id == ^post_id,
          left_join: p in ^filtered_posts,
          on: r.group_id == p.group_id and r.score > p.score,
          where: is_nil(p.id),
          select: r
        )
        |> order_by([asc: :score])
    end

    query
    |> Repo.all()
    |> Repo.preload([:group, :post])
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id),
    do:
      Repo.get!(Post, id)
      |> Repo.preload(locations: [:location, :post])

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs \\ %{}) do
    %Post{}
    |> Post.changeset(attrs)
    |> Repo.insert()
  end

  def create_post_result(attrs, score_type, result_type) do
    res =
      %PostResult{}
      |> PostResult.changeset(attrs, score_type)
      |> apply_changes()

    case result_type do
      :points ->
        loaded = Repo.preload(res, :group)
        new_score = (loaded.group.score || 0) + loaded.score

        loaded.group
        |> Groups.update_group(%{"score" => to_string(new_score)})

      :high_score ->
        {:ok}
    end

    res
    |> Repo.insert()
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end
end
