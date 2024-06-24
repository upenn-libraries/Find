import { Controller } from "@hotwired/stimulus";

// Adds error styling for inputs that have the correct action attached.
export default class extends Controller {
    // Changes styling of inputs based on whether its valid or invalid. The styling is updated for inputs that were
    // previously invalid but are now valid.
    check(input) {
        const formGroup = input.parentElement;
        const errorMessage = formGroup.querySelector('.error-message');

        if (input.validity.valid) {
            formGroup.classList.remove('form-group--error');
            errorMessage?.classList.add('d-none');
        } else {
            formGroup.classList.add('form-group--error');
            errorMessage?.classList.remove('d-none');
        }
    }

    // Display errors for any inputs that are invalid and remove errors from inputs that are now valid.
    displayErrors(event) {
        const form = this.element;

        if (!form.checkValidity()) {
           form.querySelectorAll('.form-group > input').forEach((input) => this.check(input));
        }
    }
}