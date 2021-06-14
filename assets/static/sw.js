let installPromptEvent;

window.addEventListener('beforeinstallprompt', (event) => {
  // Prevent Chrome <= 67 from automatically showing the prompt
  event.preventDefault();
  // Stash the event so it can be triggered later.
  installPromptEvent = event;
  // Update the install UI to notify the user app can be installed
  document.querySelector('#install-button').disabled = false;
});
