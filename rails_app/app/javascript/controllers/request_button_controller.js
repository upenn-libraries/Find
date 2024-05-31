import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "requestButton",
        "loginRequestButton",
    ];

    connect() {
        console.log(this.loginRequestButtonTarget);
        // if the current url contains an anchor of 'request_item', open the options frame
        if (window.location.hash === "#request_item") {
            this.requestButtonTarget.setAttribute("open", true);
        }
    }

    addQueryToUrl(event) {
        event.preventDefault();
        let url = new URL(window.location.href);

        // Get the current query parameters
        let params = new URLSearchParams(url.search);

        // Set the new or update the existing query parameter
        params.set('request', 'true');

        // Update the URL with the new query parameters
        url.search = params.toString();

        // Use history.pushState to update the address bar without reloading the page
        history.pushState({}, '', url);
        window.location.href = '/login';
    }
}
