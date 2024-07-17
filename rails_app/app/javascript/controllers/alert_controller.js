import { Controller } from "@hotwired/stimulus";
import { post } from "@rails/request.js";

export default class extends Controller {
  static targets = ["alert"];

  connect() {
    this.alertTarget.addEventListener("closed.bs.alert", () => {
      post("/alerts/dismiss");
    });
  }
}
