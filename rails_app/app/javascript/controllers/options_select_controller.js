import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "electronicButton",
    "officeButton",
    "pickupButton",
    "ill_pickupButton",
    "mailButton",
    "viewButton",
    "optionsFrame",
    "addComments",
  ];
  COMMENT_OPTIONS = ["pickup", "ill_pickup", "mail", "office"];

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
    this.toggleComments(event);
  }

  // Hide all buttons
  hideAllButtons() {
    this.buttonTargets().forEach((button) => {
      button.classList.add("d-none");
    });
  }

  // Show the comments field if the 'pickup' radio button is selected
  toggleComments(event) {
    if (this.COMMENT_OPTIONS.includes(event.target.value)) {
      this.addCommentsTarget.classList.remove("d-none");
    } else {
      this.addCommentsTarget.classList.add("d-none");
    }
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
    return this.optionsFrameTarget.querySelector(
      'input[name="delivery"]:checked',
    ).value;
  }

  // Return an array of all button targets
  buttonTargets() {
    return [
      this.electronicButtonTarget,
      this.officeButtonTarget,
      this.pickupButtonTarget,
      this.mailButtonTarget,
      this.viewButtonTarget,
      this.ill_pickupButtonTarget,
    ];
  }
}
