import React from "react";
import { toast, ToastContainer } from "react-toastify";

export default function Notifications({ handleEvent, pushEvent }) {
  if (handleEvent) {
    handleEvent("notification", (notification) =>
      toast(notification.text, {
        position: "top-center",
        autoClose: 5000,
        hideProgressBar: true,
        closeOnClick: true,
        pauseOnHover: true,
        draggable: true,
        progress: undefined,
        onClick: () => {
          pushEvent("notification-action", {
            action: notification.action,
            id: notification.id,
          });
        },
      })
    );
  }

  return (
    <ToastContainer
      toastClassName="rounded-2xl mb-3 pl-4"
      bodyClassName="font-sans font-medium text-xl text-t-black"
      position="top-center"
      autoClose={5000}
      hideProgressBar
      newestOnTop
      closeOnClick
      rtl={false}
      pauseOnFocusLoss
      draggable
      pauseOnHover
    />
  );
}
