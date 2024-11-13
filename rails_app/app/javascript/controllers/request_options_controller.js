import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "electronicButton",
    "officeButton",
    "pickupButton",
    // "ill_pickupButton",
    "mailButton",
  ];
  static outlets = ["comments"];
  COMMENTABLE = [
    "pickup",
    // "ill_pickup",
    "mail",
    "office"
  ];

  // On load of controller containing the radio buttons, check which radio button is
  // selected and show the corresponding button
  connect() {
    this.optionChanged({ target: { value: this.selectedOptionValue() } });
  }

  // Show the button corresponding to the selected radio button and display comment box if applicable to selected
  // radio button.
  // `event.target.value` will contain the new value of the radio button
  optionChanged(event) {
    this.hideAllButtons();
    this.displayButton(event.target.value);
    this.toggleComments(event.target.value); // Use outlets to call function in comment controller.
  }

  // Display the button for a delivery option
  displayButton(deliveryOption) {
    this[`${deliveryOption}ButtonTarget`].classList.remove("d-none");
  }

  // Toggle comment display based on delivery option
  toggleComments(deliveryOption) {
    this.commentsOutlet.displayComments(this.COMMENTABLE.includes(deliveryOption))
  }

  // Hide all buttons
  hideAllButtons() {
    this.buttonTargets().forEach((button) => {
      button.classList.add("d-none");
    });
  }

  // Get the value of the selected radio button
  selectedOptionValue() {
    return this.element.querySelector(
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
      // this.ill_pickupButtonTarget,
    ];
  }
}
