import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "holdingButton",
    ];

    // Add holding ID to URL on page load (or controller connect)
    connect() {
        let activeHoldingButton = this.holdingButtonTargets
            .find(button => button.classList.contains("active"));
        let activeHoldingID = activeHoldingButton.dataset.entryId;
        this.addIDToURL(activeHoldingID);
    }

    // Add holding ID to URL when a new holding is selected
    holdingChanged(event) {
        this.addIDToURL(event.currentTarget.dataset.entryId);
    }

    // Set holding ID in URL and replace current history state
    addIDToURL(id) {
        let url = new URL(window.location.href);
        url.searchParams.set('hld_id', id);
        history.replaceState({}, '', url);
    }
}
