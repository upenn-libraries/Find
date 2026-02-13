import { Controller } from "@hotwired/stimulus";

const DEFAULT_ACTIONS_COUNT = 2;
const DEFAULT_COMPLETIONS_COUNT = 4;
const MIN_QUERY_LENGTH = 1;

export default class extends Controller {
  static values = { enabled: Boolean }

  /**
   * Initializes the suggester controller when connected to the DOM.
   * Sets up event listeners for input changes and activation events.
   */
  connect() {
    this.autocomplete = this.element;
    this.input = this.autocomplete.querySelector("#query_input");
    this.debounceTimer = null;
    this.abortController = null;

    if (!this.input || !this.enabledValue) return;

    this.input.addEventListener("input", this.onInput.bind(this));
    this.observeActivation();
  }

  /**
   * Fetches suggestions from the server for the given query.
   * Aborts any in-flight requests before making a new one.
   * @param {string} query - The search query to fetch suggestions for
   */
  async fetchSuggestions(query) {
    if (this.abortController) {
      this.abortController.abort();
    }
    this.abortController = new AbortController();

    const url = `/suggester/${encodeURIComponent(query)}?actions_limit=${DEFAULT_ACTIONS_COUNT}&completions_limit=${DEFAULT_COMPLETIONS_COUNT}`;

    try {
      const response = await fetch(url, {
        signal: this.abortController.signal,
        headers: {
          Accept: "text/vnd.turbo-stream.html",
        },
      });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const html = await response.text();
      Turbo.renderStreamMessage(html);
    } catch (error) {
      if (error.name !== "AbortError") {
        console.error("Suggestion fetch failed:", error);
      }
    }
  }

  /**
   * Handles input events on the search field.
   * Debounces requests to avoid excessive API calls while the user is typing.
   * @param {Event} event - The input event from the search field
   */
  onInput(event) {
    clearTimeout(this.debounceTimer);
    const query = event.target.value.trim();
    if (query.length <= MIN_QUERY_LENGTH) {
      this.autocomplete.querySelector('ol[role="listbox"]')?.replaceChildren();
      return;
    }
    this.debounceTimer = setTimeout(() => {
      this.fetchSuggestions(query);
    }, 300);
  }

  /**
   * Sets up listener for suggestion activation events.
   * Navigates to action URLs or submits the search form when a suggestion is selected.
   */
  observeActivation() {
    this.autocomplete.addEventListener("pl:activated", (event) => {
      const { index } = event.detail;
      const listbox = this.autocomplete.querySelector('ol[role="listbox"]');
      if (!listbox) return;

      const selectedOption = listbox.children[index];
      if (!selectedOption) return;

      const actionUrl = selectedOption.dataset.actionUrl;
      if (actionUrl) {
        window.location.href = actionUrl;
      } else {
        event.preventDefault();
        this.element.querySelector("form.fi-search-box").submit();
      }
    });
  }
}
