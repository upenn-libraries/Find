import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["template"];

  connect() {
    document.addEventListener(
      "turbo:frame-missing",
      this.showTemplate.bind(this),
    );
    document.addEventListener(
      "turbo:fetch-request-error",
      this.showTemplate.bind(this),
    );
  }

  showTemplate(event) {
    if (this.hasTemplateTarget === true) {
      event.preventDefault();
      event.target.innerHTML = "";

      const clone = this.templateTarget.content.cloneNode(true);
      event.target.appendChild(clone);
    }
  }
}
