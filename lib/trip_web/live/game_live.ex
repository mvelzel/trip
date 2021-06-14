defmodule TripWeb.GameLive do
  use TripWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end

  @impl true
  def handle_event("start-game", _params, socket) do
    Trip.Games.start_game()

    {:noreply, socket}
  end

  def handle_event("stop-game", _params, socket) do
    Trip.Games.stop_game()

    {:noreply, socket}
  end
end
