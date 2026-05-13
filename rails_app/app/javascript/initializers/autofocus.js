// Re-applies focus to any `[autofocus]` element after a Turbo navigation.
//
// Turbo's cached page restores don't re-run the browser's autofocus algorithm,
// so inputs marked `autofocus` aren't focused on back/forward navigations
// (and, in practice, on initial loads where another script or component has
// not yet rendered the input by the time autofocus would have fired).
//
// We only refocus when nothing else has claimed focus, so a user who clicked
// elsewhere during the navigation doesn't get focus stolen back.
document.addEventListener('turbo:load', () => {
  const el = document.querySelector('[autofocus]')
  if (el && document.activeElement === document.body) el.focus()
})
