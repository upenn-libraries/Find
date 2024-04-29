import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "scanButton",
    "officeButton",
    "pickupButton",
    "mailButton",
    "viewButton",
    "optionsFrame",
  ];

  connect() {
    // Listen for the load of the frame containing the radio buttons
    // Check which radio button is selected and show the corresponding button
    this.optionsFrameTarget.addEventListener("turbo:frame-load", () => {
      const frameType = this.frameType();
      if (frameType === "options") {
        this.optionChanged({ target: { value: this.selectedOptionValue() } });
      } else if (frameType === "aeon") {
        this.hideAllButtons();
        this.viewButtonTarget.classList.remove("d-none");
      }
    });
  }

  // Show the button corresponding to the selected radio button
  // `event.target.value` will contain the new value of the radio button
  optionChanged(event) {
    this.hideAllButtons();
    this[`${event.target.value}ButtonTarget`].classList.remove("d-none");
  }

  // Hide all buttons
  hideAllButtons() {
    this.buttonTargets().forEach((button) => {
      button.classList.add("d-none");
    });
  }

  // Determine whether the options frame contains an element with class 'js_radio-options', 'aeon', or 'archives'
  frameType() {
    if (this.optionsFrameTarget.querySelector(".js_radio-options"))
      return "options";
    if (this.optionsFrameTarget.querySelector(".js_aeon")) return "aeon";
    if (this.optionsFrameTarget.querySelector(".js_archives"))
      return "archives";
  }

  // Get the value of the selected radio button
  selectedOptionValue() {
    return this.optionsFrameTarget.querySelector('input[name="option"]:checked')
      .value;
  }

  // Return an array of all button targets
  buttonTargets() {
    return [
      this.scanButtonTarget,
      this.officeButtonTarget,
      this.pickupButtonTarget,
      this.mailButtonTarget,
      this.viewButtonTarget,
    ];
  }
}
