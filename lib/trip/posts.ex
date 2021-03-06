defmodule Trip.Posts do
  @moduledoc """
  The Posts context.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Trip.Repo

  alias Trip.Groups
  alias Trip.Posts.{Post, PostResult, PostLocation, PostClaim}

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
    |> Repo.preload(:locations)
  end

  def list_posts_locations(location_id) do
    PostLocation
    |> where(location_id: ^location_id)
    |> Repo.all()
    |> Repo.preload(:post)
  end

  def list_all_post_claims(post_location_id) do
    PostClaim
    |> where(post_location_id: ^post_location_id)
    |> Repo.all()
    |> Repo.preload(:group)
  end

  def list_all_post_claims_group(group_id) do
    PostClaim
    |> where(group_id: ^group_id)
    |> Repo.all()
    |> Repo.preload(:group)
  end

  def list_all_post_claims(post_location_id, group_id) do
    PostClaim
    |> where(post_location_id: ^post_location_id)
    |> where(group_id: ^group_id)
    |> Repo.all()
    |> Repo.preload(:group)
  end

  def list_all_post_results(post_id) do
    PostResult
    |> where(post_id: ^post_id)
    |> Repo.all()
    |> Repo.preload(:group)
  end

  def list_post_results(post_id) do
    type = get_post!(post_id).score_type

    filtered_posts =
      from r in PostResult,
        where: r.post_id == ^post_id

    query =
      case type do
        :points ->
          from(r in PostResult,
            where: r.post_id == ^post_id,
            left_join: p in ^filtered_posts,
            on: r.group_id == p.group_id and r.score < p.score,
            where: is_nil(p.id),
            select: r
          )
          |> order_by(desc: :score)

        :time ->
          from(r in PostResult,
            where: r.post_id == ^post_id,
            left_join: p in ^filtered_posts,
            on: r.group_id == p.group_id and r.score > p.score,
            where: is_nil(p.id),
            select: r
          )
          |> order_by(asc: :score)
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

  def get_post_claims(post_location_id, round) do
    PostClaim
    |> where(post_location_id: ^post_location_id)
    |> where(round: ^round)
    |> Repo.all()
    |> Repo.preload(:group)
  end

  def get_prelim_scores(group_id) do
    from(r in PostResult,
      where: r.group_id == ^group_id,
      left_join: p in Posts,
      on: p.id == r.post_id,
      where: p.result_type == "high_score",
      select: r)
      |> order_by(desc: :score)
  end

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

  def create_post_claim(attrs \\ %{}) do
    changeset =
      %PostClaim{}
      |> PostClaim.changeset(attrs)

    changeset
    |> Repo.insert()

    Phoenix.PubSub.broadcast(Trip.PubSub, "post_claims", :post_claims)
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

  def delete_post_result(%PostResult{} = post_result) do
    post_result = Repo.preload(post_result, :post)

    case post_result.post.result_type do
      :points ->
        post_result = Repo.preload(post_result, :group)
        new_score = post_result.group.score - post_result.score

        post_result.group
        |> Groups.update_group(%{"score" => to_string(new_score)})

      :high_score ->
        {:ok}
    end

    Repo.delete(post_result)
  end

  def delete_post_claim(%PostClaim{} = post_claim) do
    Repo.delete(post_claim)
    Phoenix.PubSub.broadcast(Trip.PubSub, "post_claims", :post_claims)
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
