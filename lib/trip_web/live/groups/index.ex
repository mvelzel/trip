defmodule TripWeb.GroupsLive.Index do
  use TripWeb, :live_view

  alias Trip.Groups

  @impl true
  def mount(_params, session, socket) do
    groups = Groups.list_groups()

    {:ok,
      socket
      |> assign_defaults(session)
      |> assign(groups: groups)}
  end
end
