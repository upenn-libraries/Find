import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.addEventListener("pl:activated", (event) => {
      console.log("pl:activated:", event.detail);
    });
  }
}
