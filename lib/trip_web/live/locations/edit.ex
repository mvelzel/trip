defmodule TripWeb.LocationsLive.Edit do
  use TripWeb, :live_view

  alias Trip.Locations.Location
  alias Trip.Locations

  @impl true
  def mount(%{"location" => id}, session, socket) do
    location = Locations.get_location!(id)

    changeset =
      location
      |> Location.changeset(%{})

    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(location: location)
     |> assign(changeset: changeset)}
  end

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

  @impl true
  def handle_event(
        "validate",
        %{"location" => location_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    changeset =
      socket.assigns.location
      |> Location.changeset(location_params)
      |> Map.put(:action, :update)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("validate", %{"location" => location_params}, socket) do
    changeset =
      %Location{}
      |> Location.changeset(location_params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("set-bounds", %{"bounds" => bounds}, socket) do
    changeset =
      if Enum.count(bounds) == 2 do
        bounds
        |> Enum.with_index()
        |> Enum.reduce(socket.assigns.changeset, fn {[lat, lon], i}, ch ->
          ch
          |> Ecto.Changeset.put_change(String.to_atom("lat#{i}"), lat)
          |> Ecto.Changeset.put_change(String.to_atom("lon#{i}"), lon)
        end)
        |> Location.validate_changeset()
      else
        socket.assigns.changeset
      end

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event(
        "create",
        %{"location" => location_params},
        %{assigns: %{live_action: :edit}} = socket
      ) do
    {:ok, _} = Locations.update_location(socket.assigns.location, location_params)

    {:noreply, push_redirect(socket, to: Routes.locations_index_path(socket, :index))}
  end

  def handle_event("create", %{"location" => location_params}, socket) do
    {:ok, _} = Locations.create_location(location_params)

    {:noreply, push_redirect(socket, to: Routes.locations_index_path(socket, :index))}
  end

  defp generate_bounds(changeset) do
    lat0 = changeset |> Ecto.Changeset.get_field(:lat0)
    lon0 = changeset |> Ecto.Changeset.get_field(:lon0)
    lat1 = changeset |> Ecto.Changeset.get_field(:lat1)
    lon1 = changeset |> Ecto.Changeset.get_field(:lon1)

    if is_nil(lat0) || is_nil(lat1) || is_nil(lon0) || is_nil(lon1) do
      []
    else
      [[lat0, lon0], [lat1, lon1]]
    end
  end
end
