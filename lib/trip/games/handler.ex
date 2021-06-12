defmodule Trip.Games.Handler do
  use GenServer

  alias Trip.Games

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    if Trip.Games.list_games() |> Enum.count() == 0 do
      Trip.Games.create_game()
    end

    Phoenix.PubSub.subscribe(Trip.PubSub, "game")

    {:ok,
     state
     |> Map.put(:game, Games.get_game!())}
  end

  @impl true
  def handle_info(%Games.Game{} = game, state) do
    if !state.game.started && game.started do
      diff =
        game.time_started
        |> NaiveDateTime.diff(NaiveDateTime.utc_now(), :millisecond)

      Process.send_after(self(), :increment_round, 15 * 60 * 1000 + diff)
    end

    {:noreply,
     state
     |> Map.put(:game, game)}
  end

  def handle_info(:increment_round, state) do
    changeset =
      state.game
      |> Games.Game.changeset(%{"current_round" => to_string(state.game.current_round + 1)})

    game = Ecto.Changeset.apply_changes(changeset)

    IO.inspect(game.current_round)

    changeset
    |> Trip.Repo.update()

    if game.started do
      Process.send_after(self(), :increment_round, 15 * 60 * 1000)
    end

    {:noreply,
     state
     |> Map.put(:game, game)}
  end
end
