import { Controller } from "@hotwired/stimulus";

// Adds error styling for inputs that have the correct action attached.
export default class extends Controller {
    // Changes styling of inputs if its invalid.
    check(event) {
        console.log(event);
        const input = event.target;
        const formGroup = input.parentElement;
        const errorMessage = formGroup.querySelector('.error-message');

        if (input.validity.valid) {
            formGroup.classList.remove('form-group--error');
            errorMessage.classList.add('d-none');
        } else {
            formGroup.classList.add('form-group--error');
            errorMessage.classList.remove('d-none');
        }
    }
}