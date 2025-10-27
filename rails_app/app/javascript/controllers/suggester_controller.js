import { Controller } from "@hotwired/stimulus";

const RESPONSE = {
  status: "success",
  data: {
    params: { q: "query", context: [5] },
    suggestions: {
      actions: [
        {
          label: 'query in Title',
          url: "http://localhost:3000/?field=title&q=query",
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
    this.autocomplete = this.element; // <pennlibs-autocomplete>
    this.renderSuggestions(RESPONSE.data.suggestions);
    this.observeActivation();
  }

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
      // li.innerHTML = this.markQuery(text);
      li.innerHTML = text;
      ol.appendChild(li);
    });
  }

  addActions(ol, actions) {
    actions.forEach((action) => {
      const li = document.createElement("li");
      li.setAttribute("role", "option");
      li.dataset.plValue = action.label;
      // li.innerHTML = this.markQuery(action.label);
      li.innerHTML = action.label;
      ol.appendChild(li);
    });
  }

  replaceListbox(ol) {
    const existing = this.autocomplete.querySelector('ol[role="listbox"]');
    if (existing) existing.remove();
    this.autocomplete.appendChild(ol);
  }

  // markQuery(text) {
  //   const re = new RegExp(`(${RESPONSE.data.params.q})`, "ig");
  //   return text.replace(re, "<mark>$1</mark>");
  // }

  observeActivation() {
    this.autocomplete.addEventListener("pl:activated", (event) => {
      const { index, value } = event.detail;
      const suggestions = RESPONSE.data.suggestions;
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
