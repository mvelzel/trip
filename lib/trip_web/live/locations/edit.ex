defmodule TripWeb.LocationsLive.Edit do
  use TripWeb, :live_view

  alias Trip.Locations.Location

  @impl true
  def mount(_params, session, socket) do
    changeset =
      %Location{}
      |> Location.changeset(%{})

    {:ok,
      socket
      |> assign_defaults(session)
      |> assign(changeset: changeset)}
  end


  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset =
      %Location{}
      |> Location.changeset(location_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end
end
