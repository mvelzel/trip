defmodule TripWeb.LocationsLive.Index do
  use TripWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok,
      socket
      |> assign_defaults(session)}
  end
end
