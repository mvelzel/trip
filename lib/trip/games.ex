defmodule Trip.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Trip.Repo

  alias Trip.Games.Game

  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  def get_game!(),
    do:
      Repo.all(Game)
      |> Enum.at(0)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(attrs) do
    game = get_game!()

    changeset =
      game
      |> Game.changeset(attrs)

    Phoenix.PubSub.broadcast(Trip.PubSub, "game", Ecto.Changeset.apply_changes(changeset))
    Phoenix.PubSub.broadcast(Trip.PubSub, "game_front", Ecto.Changeset.apply_changes(changeset))

    changeset
    |> Repo.update()
  end

  def update_game(attrs, time) do
    game = get_game!()

    changeset =
      game
      |> Game.changeset(attrs)
      |> Ecto.Changeset.put_change(:time_started, time)

    Phoenix.PubSub.broadcast(Trip.PubSub, "game", Ecto.Changeset.apply_changes(changeset))
    Phoenix.PubSub.broadcast(Trip.PubSub, "game_front", Ecto.Changeset.apply_changes(changeset))

    changeset
    |> Repo.update()
  end

  def start_game() do
    {{y, m, d}, {h, min, s}} =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.to_erl()

    ss = min * 60 + s

    {hnew, minnew} = case ss do
      _sec when ss < 450 -> {h, 0}
      _sec when ss >= 450 and ss < 1350 -> {h, 15}
      _sec when ss >= 1350 and ss < 2250 -> {h, 30}
      _sec when ss >= 2250 and ss < 3150 -> {h, 45}
      _sec when ss >= 3150 -> {h + 1, 0}
    end

    time_started = NaiveDateTime.new!(y, m, d, hnew, minnew, 0)

    Repo.delete_all(Trip.Posts.PostClaim)
    update_game(%{"started" => "true", "current_round" => "0"}, time_started)
  end

  def stop_game() do
    Repo.delete_all(Trip.Posts.PostClaim)
    Phoenix.PubSub.broadcast(Trip.PubSub, "post_claims", :post_claims)
    update_game(%{"started" => "false", "current_round" => "0"})
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end
end
