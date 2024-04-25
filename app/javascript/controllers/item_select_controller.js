import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "select",
    "mmsIdField",
    "holdingIdField",
    "commentsArea",
    "optionsFrame",
    "optionsLoadingTemplate",
  ];

  selectChanged(event) {
    const mmsIdValue = this.mmsIdFieldTarget.value;
    const holdingValue = this.holdingIdFieldTarget.value;
    const itemValue = event.target.value;
    const url = `/account/requests/options?mms_id=${mmsIdValue}&holding_id=${holdingValue}&item_pid=${itemValue}`;

    if (itemValue.length > 0) {
      this.optionsFrameTarget.src = url;
      this.optionsFrameTarget.innerHTML =
        this.optionsLoadingTemplateTarget.innerHTML;
    }
  }
}
