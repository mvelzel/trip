// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "react-toastify/dist/ReactToastify.css";
import "../css/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "phoenix_html";
import { Socket } from "phoenix";
import NProgress from "nprogress";
import { LiveSocket } from "phoenix_live_view";
import LiveReact, { initLiveReact } from "phoenix_live_react";
import { MapBoundsPicker, MapLocationPicker } from "./react/embed/MapEditor";
import MapOverview from "./react/embed/MapOverview";
import Notifications from "./react/embed/Notifications";
import Leaderboards from "./react/embed/Leaderboards";
import Dropdown from "./react/embed/Dropdown";
import "alpinejs";

let Hooks = { LiveReact };

Hooks.Notifications = {
  mounted() {
    Notification.requestPermission().then((result) => {
      if (result === "granted") {
      }
    });
    this.handleEvent("service-notification", ({ text }) => {
      navigator.serviceWorker.getRegistration().then(function (reg) {
        reg.showNotification(text, {
          body: text,
          icon: "/images/icon-192x192.png",
          badge: "/images/icon-96x96.png",
          image: "/images/icon-512x512.png",
          vibrate: [300, 100, 300],
        });
      });
    });
  },
};

// Hooks.Example = { mounted() { } }

window.Components = {
  MapBoundsPicker,
  MapLocationPicker,
  Dropdown,
  Leaderboards,
  MapOverview,
  Notifications,
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) {
        window.Alpine.clone(from.__x, to);
      }
    },
  },
});

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", (info) => NProgress.start());
window.addEventListener("phx:page-loading-stop", (info) => NProgress.done());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Optionally render the React components on page load as
// well to speed up the initial time to render.
// The pushEvent, pushEventTo and handleEvent props will not be passed here.
document.addEventListener("DOMContentLoaded", (e) => {
  initLiveReact();
});

window.addEventListener("beforeinstallprompt", (e) => {
});
