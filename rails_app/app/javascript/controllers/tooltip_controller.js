import { Controller } from "@hotwired/stimulus";
import bootstrap from "bootstrap";

export default class extends Controller {
  static values = {
    contentSelector: String,
  };

  connect() {
    this.tooltip = new bootstrap.Tooltip(this.element, {
      container: "body",
      trigger: "hover focus",
    });
  }

  disconnect() {
    this.tooltip?.dispose();
  }

  refresh(event) {
    if (event?.target && !event.target.contains(this.element)) return;

    const content = this.currentContent();
    if (!content) return;

    this.element.setAttribute("aria-label", content);
    this.element.setAttribute("data-bs-title", content);
    this.tooltip?.setContent({ ".tooltip-inner": content });
  }

  currentContent() {
    if (this.hasContentSelectorValue) {
      const source = this.element.querySelector(this.contentSelectorValue);
      if (source?.textContent) return source.textContent.trim();
    }

    return this.element.getAttribute("data-bs-title");
  }
}
