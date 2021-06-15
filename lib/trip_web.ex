defmodule TripWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use TripWeb, :controller
      use TripWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: TripWeb

      import Plug.Conn
      import TripWeb.Gettext
      alias TripWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/trip_web/templates",
        namespace: TripWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        container: {:div, class: "h-full w-full flex"},
        layout: {TripWeb.LayoutView, "live.html"}

      unquote(view_helpers())

      @impl true
      def handle_event("burger", _params, socket) do
        {:noreply, assign(socket, menu_expanded: !socket.assigns.menu_expanded)}
      end

      def handle_event("notification-action", %{"action" => action, "id" => id}, socket) do
        if !action do
          {:noreply, push_redirect(socket, to: Routes.notifications_index_path(socket, :index))}
        else
          Trip.Notifications.mark_as_read(id)
          {:noreply, push_redirect(socket, to: action)}
        end
      end

      @impl true
      def handle_info(%Trip.Notifications.Notification{} = n, socket) do
        Phoenix.PubSub.broadcast(
          Trip.PubSub,
          "local_not:#{socket.assigns.current_user.id}",
          {:local_not, n}
        )

        {:noreply,
         socket
         |> assign(notification_count: socket.assigns.notification_count + 1)
         |> push_event("notification", n)}
      end

      def handle_info(%Trip.Games.Game{} = game, socket) do
        if game.started && game.started != socket.assigns.game.started do
          not_text = gettext("The game has begun!")

          Trip.Notifications.notify_all(%{
            "text" => not_text,
            "priority" => "urgent",
            "action" => Routes.index_path(socket, :index)
          })
        end

        if game.started && game.current_round != socket.assigns.game.current_round do
          not_text = gettext("New round has begun: ") <> "#{game.current_round}"
          Trip.Notifications.notify_all(%{"text" => not_text, "priority" => "normal"})
        end

        {:noreply,
         socket
         |> assign(game: game)}
      end

      def assign_defaults(socket, session) do
        current_user =
          if Map.has_key?(session, "user_token") do
            Trip.Accounts.get_user_by_session_token(Map.get(session, "user_token"))
          else
            nil
          end

        notifications =
          if current_user do
            Phoenix.PubSub.unsubscribe(Trip.PubSub, "notification:#{current_user.id}")
            Phoenix.PubSub.subscribe(Trip.PubSub, "notification:#{current_user.id}")

            notifications =
              Trip.Notifications.list_unread_notifications(current_user.id)
              |> Enum.count()
          else
            0
          end

        Phoenix.PubSub.unsubscribe(Trip.PubSub, "game_front")
        Phoenix.PubSub.subscribe(Trip.PubSub, "game_front")

        socket
        |> assign(current_user: current_user)
        |> assign(notification_count: notifications)
        |> assign(game: Trip.Games.get_game!())
        |> assign(menu_expanded: false)
      end
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(view_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import TripWeb.Gettext
    end
  end

  defp view_helpers do
    quote do
      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      # Import LiveView helpers (live_render, live_component, live_patch, etc)
      import Phoenix.LiveView.Helpers

      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      import PhoenixLiveReact
      import TripWeb.UserAuth

      import TripWeb.ErrorHelpers
      import TripWeb.Gettext
      alias TripWeb.Router.Helpers, as: Routes

      def result_type_label(:points), do: gettext("Battle")
      def result_type_label(:high_score), do: gettext("Highscore")
      def score_type_label(:points), do: gettext("Points")
      def score_type_label(:time), do: gettext("Time")

      def role_label(:admin), do: gettext("Admin")
      def role_label(:player), do: gettext("Player")
      def role_label(:postleader), do: gettext("Postleader")
      def role_label(:judge), do: gettext("Judge")

      def submission_status_label(:pending), do: gettext("Pending")
      def submission_status_label(:passed), do: gettext("Passed")
      def submission_status_label(:unsubmitted), do: gettext("Not submitted")
      def submission_status_label(:failed), do: gettext("Failed")
      def submission_type_label(:text), do: gettext("Text")
      def submission_type_label(:image), do: gettext("Image")

      def base64_image(binary) do
        "data:image/png;base64, " <> Base.encode64(binary)
      end
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
