import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "entryButton",
    ];

    // Add holding ID to URL on page load (or controller connect)
    connect() {
        let activeEntryButton = this.entryButtonTargets
            .find(button => button.classList.contains("active"));
        let activeEntryID = activeEntryButton.dataset.entryId;
        this.addIDToURL(activeEntryID);
    }

    // Add holding ID to URL when a new holding is selected
    entryChanged(event) {
        this.addIDToURL(event.currentTarget.dataset.entryId);
    }

    // Set holding ID in URL and replace current history state
    addIDToURL(id) {
        let url = new URL(window.location.href);
        if(id.length > 0) {
            url.searchParams.set('hld_id', id);
        } else {
            url.searchParams.delete('hld_id');
        }
        history.replaceState(history.state, '', url);
    }
}
