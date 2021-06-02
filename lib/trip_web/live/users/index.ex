defmodule TripWeb.UsersLive.Index do
  use TripWeb, :live_view

  alias Trip.Accounts

  @impl true
  def mount(_params, session, socket) do
    users = Accounts.list_users()

    {:ok,
      socket
      |> assign_defaults(session)
      |> assign(users: users)}
  end
end
