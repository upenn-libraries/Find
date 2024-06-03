import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "requestButton"
    ];

    connect() {
        // if the current url contains an anchor of 'request_item', open the options frame
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('request') == 'true') {
            this.requestButtonTarget.setAttribute("open", true);
        }
    }

    addQueryToUrl(event) {
        // Preventing browser from automatically following link before we can add to the history.
        event.preventDefault();

        // Get window URL
        let url = new URL(window.location.href);

        // Get the current query parameters
        let params = new URLSearchParams(url.search);

        // Set the new or update the existing query parameter
        params.set('request', 'true');

        // Update the URL with the new query parameters
        url.search = params.toString();

        // Use history.pushState to update the address bar without reloading the page
        history.pushState({}, '', url);

        // Follow link.
        window.location.href = event.target.href;
    }
}
