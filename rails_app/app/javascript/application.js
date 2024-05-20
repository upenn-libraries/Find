// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "popper";
import "bootstrap";
import Blacklight from "blacklight";

class SearchList extends HTMLElement {
  constructor() {
    super();

    const LIST_LENGTH_THRESHOLD = 12;

    this.searchableNodes = this.childNodes;

    if (this.childElementCount > LIST_LENGTH_THRESHOLD) {
      this.addSearch();
    }
  }

  connectedCallback() {
    this.inputEl.addEventListener('input', this.search.bind(this))
  }

  disconnectedCallback() {
    this.inputEl.removeEventListener('input')
  }

  addSearch() {
    let containerEl = document.createElement('div');
    containerEl.setAttribute("class", "search-list")

    let inputEl = document.createElement('input');
    inputEl.setAttribute("type", "text");
    inputEl.setAttribute("class", "form-control search-list__input")
    inputEl.setAttribute("placeholder", "Search options");
    inputEl.setAttribute("aria-label", "Search options");

    containerEl.appendChild(inputEl);

    this.prepend(containerEl);
    this.inputEl = inputEl;
  }

  search() {
    const term = this.inputEl.value.toLowerCase();
    const elements = this.querySelectorAll('.inventory-item');

    elements.forEach(node => {
      if (node.textContent.toLowerCase().includes(term) || term.length === 0) {
        node.removeAttribute('hidden')
      } else {
        node.setAttribute('hidden', true)
      }
    })
  }
}

customElements.define("search-list", SearchList)