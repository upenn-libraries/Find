import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "holdingButton",
    ];

    connect() {
        let activeHoldingButton = this.holdingButtonTargets
            .find(button => button.classList.contains("active"));
        let activeHoldingID = activeHoldingButton.dataset.entryId;
        this.addIDToURL(activeHoldingID);
    }

    holdingChanged(event) {
        this.addIDToURL(event.currentTarget.dataset.entryId);
    }

    addIDToURL(id) {
        let url = new URL(window.location.href);
        url.searchParams.set('hld_id', id);
        history.replaceState({}, '', url);
    }
}
