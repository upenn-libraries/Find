import { Controller } from "@hotwired/stimulus";

const RESPONSE = {
  status: "success",
  data: {
    params: { q: "query", context: [5] },
    suggestions: {
      actions: [
        {
          label: 'Search titles for "query"',
          url: "https://find.library.upenn.edu/?field=title&q=query",
        },
      ],
      completions: [
        "query syntax",
        "query language",
        "query errors",
        "adversarial queries",
      ],
    },
  },
};

export default class extends Controller {
  connect() {
    this.autocomplete = this.element;
    this.renderSuggestions(RESPONSE.data.suggestions);
    this.observeActivation();
  }

  renderSuggestions(suggestions) {
    this.clearExistingListbox();
    const listbox = this.createListbox();

    this.addCompletions(listbox, suggestions.completions);
    this.addActions(listbox, suggestions.actions);

    this.autocomplete.appendChild(listbox);
    this.notifyComponentOfChanges();
  }

  clearExistingListbox() {
    const existing = this.autocomplete.querySelector('ol[role="listbox"]');
    if (existing) existing.remove();
  }

  createListbox() {
    const ol = document.createElement("ol");
    ol.setAttribute("role", "listbox");
    return ol;
  }

  addCompletions(listbox, completions = []) {
    completions.forEach((text) => {
      listbox.appendChild(this.createCompletionOption(text));
    });
  }

  addActions(listbox, actions = []) {
    actions.forEach((action) => {
      listbox.appendChild(this.createActionOption(action));
    });
  }

  createCompletionOption(text) {
    const li = document.createElement("li");
    li.setAttribute("role", "option");
    li.setAttribute("data-pl-value", text);
    li.textContent = text;
    return li;
  }

  createActionOption(action) {
    const li = document.createElement("li");
    li.setAttribute("role", "option");
    li.setAttribute("data-pl-value", action.label);
    li.innerHTML = `<a href="${action.url}">${action.label}</a>`;
    return li;
  }

  notifyComponentOfChanges() {
    // Triggers the Stencil component to re-scan its DOM
    this.autocomplete.dispatchEvent(new Event("slotchange"));
  }

  observeActivation() {
    this.autocomplete.addEventListener("pl:activated", (event) => {
      const { value } = event.detail;
      console.log("Activated:", value);

      const match = RESPONSE.data.suggestions.actions.find(
        (a) => a.label === value,
      );

      if (match) {
        window.location.href = match.url;
      }
    });
  }
}
