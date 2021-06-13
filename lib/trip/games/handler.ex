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
    state = if !state.game.started && game.started do
      diff =
        game.time_started
        |> NaiveDateTime.diff(NaiveDateTime.utc_now(), :millisecond)

      #time_increment(state, 15 * 60 * 1000 + diff)
      time_increment(state, 1 * 60 * 1000)
    else
      if state.game.started && !game.started do
        stop_timer(state)
      else
        state
      end
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

    Phoenix.PubSub.broadcast(Trip.PubSub, "game_front", Ecto.Changeset.apply_changes(changeset))

    changeset
    |> Trip.Repo.update()

    state = if game.started do
      #time_increment(state, 15 * 60 * 1000)
      time_increment(state, 1 * 60 * 1000)
    end

    {:noreply,
     state
     |> Map.put(:game, game)}
  end

  defp time_increment(state, time) do
    if state[:timer] do
      Process.cancel_timer(state.timer)
    end
    timer = Process.send_after(self(), :increment_round, time)
    state |> Map.put(:timer, timer)
  end

  defp stop_timer(state) do
    if state[:timer] do
      Process.cancel_timer(state.timer)
      state |> Map.delete(:timer)
    else
      state
    end
  end
end
