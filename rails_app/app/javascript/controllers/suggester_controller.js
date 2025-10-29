import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  /**
   * Initializes the suggester controller when connected to the DOM.
   * Sets up event listeners for input changes and activation events.
   */
  connect() {
    this.autocomplete = this.element;
    this.input = this.autocomplete.querySelector("#query_input");
    this.latestSuggestions = null;
    this.debounceTimer = null;
    this.abortController = null;

    if (!this.input) return;

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

    const url = `/suggester/${encodeURIComponent(query)}?count=5`;

    try {
			// this takes an abort signal to allow canceling the async request to fetch suggestions
			// if a new request is made, i.e. a new character is added to the query
      const response = await fetch(url, { signal: this.abortController.signal });
      if (!response.ok) throw new Error(`HTTP ${response.status}`);
      const data = await response.json();
      if (data.status === "success") {
        this.latestSuggestions = data.data.suggestions;
        this.renderSuggestions(data.data.suggestions);
      }
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
    const query = event.target.value.trim();
    if (query.length < 2) return;

		// clear any pending timeout from previous input events to prevent overlapping requests
    clearTimeout(this.debounceTimer);
		// ensure the API is only called once after the user stops typing for 300ms rather than every keystroke
    this.debounceTimer = setTimeout(() => {
      this.fetchSuggestions(query);
    }, 300);
  }

  /**
   * Renders the suggestions list in the DOM.
   * Creates a listbox element and populates it with completions and actions.
   * @param {Object} suggestions - Object containing completions and actions arrays
   */
  renderSuggestions(suggestions) {
    const ol = this.createListbox();
    this.addCompletions(ol, suggestions.completions);
    this.addActions(ol, suggestions.actions);
    this.replaceListbox(ol);
  }

  createListbox() {
    const ol = document.createElement("ol");
    ol.setAttribute("role", "listbox");
    return ol;
  }

  addCompletions(ol, completions) {
    completions.forEach((text) => {
      const li = document.createElement("li");
      li.setAttribute("role", "option");
      li.textContent = text;
      ol.appendChild(li);
    });
  }

  addActions(ol, actions) {
    actions.forEach((action) => {
      const li = document.createElement("li");
      li.setAttribute("role", "option");
      li.dataset.plValue = action.label;
      li.textContent = action.label;
      ol.appendChild(li);
    });
  }

  replaceListbox(ol) {
    const existing = this.autocomplete.querySelector('ol[role="listbox"]');
    if (existing) existing.remove();
    this.autocomplete.appendChild(ol);
    this.autocomplete.dispatchEvent(new Event("slotchange", { bubbles: true }));
  }

  /**
   * Sets up listener for suggestion activation events.
   * Navigates to action URLs or submits the search form when a suggestion is selected.
   */
  observeActivation() {
    this.autocomplete.addEventListener("pl:activated", (event) => {
      const { index } = event.detail;
      const suggestions = this.latestSuggestions;
      const action =
        suggestions.actions[index - suggestions.completions.length];
      if (action) {
        window.location.href = action.url;
      } else {
        this.element.querySelector("form.fi-search-box").submit();
      }
    });
  }
}
