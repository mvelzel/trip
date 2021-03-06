defmodule TripWeb.NotificationsLive.Index do
  use TripWeb, :live_view

  alias Trip.Notifications

  @impl true
  def mount(_params, session, socket) do
    socket = assign_defaults(socket, session)

    current_user = socket.assigns.current_user

    notifications = Notifications.list_notifications(current_user.id)

    Notifications.mark_all_read(current_user.id)

    {:ok,
     socket
     |> assign(notifications: notifications)}
  end

  @impl true
  def handle_event("clear", _params, socket) do
    Notifications.delete_all_read(socket.assigns.current_user.id)

    {:noreply, push_redirect(socket, to: Routes.notifications_index_path(socket, :index))}
  end
end
