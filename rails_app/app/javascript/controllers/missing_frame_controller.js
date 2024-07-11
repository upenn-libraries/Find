import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    document.addEventListener("turbo:frame-missing", event => {
      event.preventDefault();
      const message = this.message(event.target.id);
      event.target.innerHTML = `<div class="alert alert-warning">${message}. Please try again.</div>`;
    });
  }

  message(frameId) {
    if (frameId.includes("options")) return "We're having trouble getting the requesting options for this item";
    if (frameId.includes("inventory")) return "We're having trouble getting the availability for this item";
    if (frameId.includes("summon")) return "We're having trouble getting additional results";
    return "Something went wrong";
  }
}