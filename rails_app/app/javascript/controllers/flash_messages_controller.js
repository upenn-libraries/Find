import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.observer = new MutationObserver(() => {
      if (this.element.children.length === 0) {
        this.element.remove();
      }
    });

    this.observer.observe(this.element, { childList: true });
  }

  disconnect() {
    this.observer?.disconnect();
  }
}
