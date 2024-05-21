// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "popper";
import "bootstrap";
import Blacklight from "blacklight";

/**
 * Search List custom element adds search
 * functionaility by keyword on the textContent
 * of elements with the [data-search-list-item]
 * attribute.
 * 
 * Example HTML:
 * 
 * <search-list>
 *   <ul>
 *     <li data-search-list-item></li>
 *     <li data-search-list-item></li>
 *   </ul>
 * </search-list>
 */
class SearchList extends HTMLElement {
  constructor() {
    super();

    const LIST_LENGTH_THRESHOLD = 9;

    this.searchableElements = this.querySelectorAll('[data-search-list-item]');

    if (this.searchableElements.length > LIST_LENGTH_THRESHOLD) {
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
    inputEl.setAttribute("placeholder", "Search this list");
    inputEl.setAttribute("aria-label", "Search this list");

    containerEl.appendChild(inputEl);

    this.prepend(containerEl);
    this.inputEl = inputEl;
  }

  search() {
    // Remove any existing no results elements
    this.querySelectorAll('.search-list__no-results').forEach(el => el.remove());

    // 
    const term = this.inputEl.value.toLowerCase();
    let visibleElements = 0;

    this.searchableElements.forEach(node => {
      if (node.textContent.toLowerCase().includes(term) || term.length === 0) {
        node.removeAttribute('hidden')
        visibleElements++
      } else {
        node.setAttribute('hidden', true)
      }
    })

    let noResultsElement = document.createElement('small');
    noResultsElement.setAttribute("class", "search-list__no-results text-muted");

    if (visibleElements === 0) {
      noResultsElement.textContent = `No results for "${term}"`
    } else {
      noResultsElement.textContent = `${visibleElements} of ${this.searchableElements.length} results for "${term}"`
    }

    if (term.length > 0) {
      this.inputEl.insertAdjacentElement('afterend', noResultsElement);
    }
  }
}

customElements.define("search-list", SearchList)