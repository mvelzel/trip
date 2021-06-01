defmodule TripWeb.LocationsLive.Index do
  use TripWeb, :live_view

  alias Trip.Locations

  @impl true
  def mount(_params, session, socket) do
    locations = Locations.list_locations()

    {:ok,
      socket
      |> assign_defaults(session)
      |> assign(locations: locations)}
  end
end
