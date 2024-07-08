import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "search",
    "input",
    "description",
    "entry"
  ];

  connect() {
    const ENTRY_THRESHOLD = 9;

    if (this.entryTargets.length >= ENTRY_THRESHOLD) {
      this.searchTarget.classList.remove('d-none');
    }
  }

  search() {
    let query = this.inputTarget.value.toLowerCase();
    let results = 0;

    this.entryTargets.forEach(node => {
      if (
        query.length === 0 ||
        node.textContent.toLowerCase().includes(query)
      ) {
        node.removeAttribute('hidden')
        results++
      } else {
        node.setAttribute('hidden', true)
      }

      if (node.matches('[aria-selected=true]')) {
        node.removeAttribute('hidden')
      }
    })

    if (results === 0) {
      this.descriptionTarget.textContent = `No results for "${query}"`;
    } else {
      this.descriptionTarget.textContent = `${results} of ${this.entryTargets.length} results for "${query}"`;
    }

    if (query.length > 0) {
      this.descriptionTarget.classList.remove('d-none')
    } else {
      this.descriptionTarget.classList.add('d-none')
    }
  }
}