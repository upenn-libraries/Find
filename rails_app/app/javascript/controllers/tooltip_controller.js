import { Controller } from "@hotwired/stimulus";
import bootstrap from "bootstrap";

export default class extends Controller {
  connect() {
    this.tooltip = new bootstrap.Tooltip(this.element);
  }

  disconnect() {
    this.tooltip?.dispose();
  }
}
