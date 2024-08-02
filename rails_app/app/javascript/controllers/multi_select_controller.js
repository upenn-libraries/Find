import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  static values = {
    plugins: Array,
  };

  connect() {
    this.select = new TomSelect(this.element, {
      plugins: this.pluginsValue,
      render: {
        item: function (data, escape) {
          return `<div>${escape(data.value)}</div>`;
        },
      },
    });
  }

  disconnect() {
    this.select?.destroy();
  }
}
