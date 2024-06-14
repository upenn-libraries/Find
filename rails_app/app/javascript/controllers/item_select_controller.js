import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "select",
    "mmsIdField",
    "holdingIdField",
    "itemIdField",
    "optionsFrame",
    "optionsLoadingTemplate",
  ];

  connect() {
    if (!this.hasSelectTarget) {
      this.updateOptionsFrame(this.buildUrl(this.itemIdFieldTarget.value));
    }
  }

  selectChanged(event) {
    if (event.target.value.length > 0) {
      this.updateOptionsFrame(this.buildUrl(event.target.value));
    }
  }

  buildUrl(itemValue) {
    return `/account/requests/options?mms_id=${this.mmsIdFieldTarget.value}&holding_id=${this.holdingIdFieldTarget.value}&item_id=${itemValue}`;
  }

  updateOptionsFrame(url) {
    this.optionsFrameTarget.src = url;
    this.optionsFrameTarget.innerHTML =
      this.optionsLoadingTemplateTarget.innerHTML;
  }
}
