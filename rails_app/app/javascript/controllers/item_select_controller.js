import { Controller } from "@hotwired/stimulus";

// Swaps out the source url in the options turbo frame when a user selects a new item.sa
export default class extends Controller {
  static targets = [
    "mmsIdField",
    "holdingIdField",
    "optionsFrame",
    "optionsLoadingTemplate",
  ];

  selectChanged(event) {
    if (event.target.value.length > 0) {
      this.updateOptionsFrame(this.buildUrl(event.target.value));
    }
  }

  buildUrl(itemValue) {
    return `/fulfillment/options?mms_id=${this.mmsIdFieldTarget.value}&holding_id=${this.holdingIdFieldTarget.value}&item_id=${itemValue}`;
  }

  updateOptionsFrame(url) {
    this.optionsFrameTarget.src = url;
    this.optionsFrameTarget.innerHTML =
      this.optionsLoadingTemplateTarget.innerHTML;
  }
}
