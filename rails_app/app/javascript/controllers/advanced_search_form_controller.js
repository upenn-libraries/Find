import { Controller } from "@hotwired/stimulus";

// attaches to Find::AdvancedSearchForm component
export default class extends Controller {
    static targets = ["form"];

    // dispatch submit event on advanced search page form to other controllers listening
    submit(event) {
        this.dispatch("submit");
    }
}
