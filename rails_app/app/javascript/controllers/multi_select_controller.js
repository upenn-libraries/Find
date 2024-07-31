import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  static values = {
    plugins: Array,
  };

  connect() {
    this.initTomSelect();
  }

  disconnect() {
    if (this.select) {
      this.select.destroy();
    }
  }

  initTomSelect() {
    if (this.element) {
      this.select = new TomSelect(this.element, {
        plugins: this.pluginsValue,
      });
    }
  }
}
