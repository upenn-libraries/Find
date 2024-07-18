import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { error: String };

  connect() {
    this.element.addEventListener(
      "turbo:frame-missing",
      this.showError.bind(this),
    );
    this.element.addEventListener(
      "turbo:fetch-request-error",
      this.showError.bind(this),
    );
  }

  showError(event) {
    event.preventDefault();
    event.target.innerHTML = `<div class="alert alert-warning">${this.errorValue}</div>`;
  }
}
