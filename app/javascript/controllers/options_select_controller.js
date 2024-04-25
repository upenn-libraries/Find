import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "requestScanButton",
    "requestDeliveryButton",
    "requestPickupButton",
    "requestMailButton",
    "requestViewButton",
    "optionsFrame",
  ];

  connect() {
    // Listen for the load of the frame containing the radio buttons.
    // Check which radio button is selected and show the corresponding button.
    this.optionsFrameTarget.addEventListener("turbo:frame-load", () => {
      switch (this.frameType()) {
        case "options":
          const selectedOption = document.querySelector(
            'input[name="option"]:checked',
          ).value;
          this.optionChanged({ target: { value: selectedOption } });
          break;
        case "aeon":
          this.showButton(this.requestViewButtonTarget);
          break;
      }
    });
  }

  optionChanged(event) {
    // This method will be called when the value of the radio button changes.
    // `event.target.value` will contain the new value of the radio button.
    switch (event.target.value) {
      case "scan":
        this.showButton(this.requestScanButtonTarget, event);
        break;
      case "office":
        this.showButton(this.requestDeliveryButtonTarget, event);
        break;
      case "pickup":
        this.showButton(this.requestPickupButtonTarget, event);
        break;
      case "mail":
        this.showButton(this.requestMailButtonTarget, event);
        break;
      default:
        this.hideAllButtons();
    }
  }

  showButton(target, event) {
    this.hideAllButtons();
    target.classList.remove("d-none");
  }

  hideAllButtons() {
    [
      this.requestScanButtonTarget,
      this.requestDeliveryButtonTarget,
      this.requestPickupButtonTarget,
      this.requestMailButtonTarget,
      this.requestViewButtonTarget,
    ].forEach((button) => {
      button.classList.add("d-none");
    });
  }

  // Determine whether the options frame contains a div with class 'options', 'aeon', or 'archives'.
  frameType() {
    if (this.optionsFrameTarget.querySelector(".radio-options")) {
      return "options";
    } else if (this.optionsFrameTarget.querySelector(".aeon")) {
      return "aeon";
    } else if (this.optionsFrameTarget.querySelector(".archives")) {
      return "archives";
    }
  }
}
