import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "requestButton"
    ];

    connect() {
        // If the current url contains a 'request=true' query param, open the options frame
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('request') == 'true') {
            this.requestButtonTarget.setAttribute("open", true);
        }
    }


    // Begin loading the fulfillment form frame on hover so the Alma API calls are already
    // in flight by the time the user clicks and the <details> opens.
    prefetch() {
        const frame = this.element.querySelector('turbo-frame');
        if (frame && frame.getAttribute('loading') === 'lazy') {
            frame.setAttribute('loading', 'eager');
        }
    }

    // Add a 'request=true' query param to the current url and follow the link. This allows us to open the options
    // frame on redirect after signing in.
    addRequestQueryToUrl(event) {
        // Preventing browser from automatically following link before we can add to the history.
        event.preventDefault();
        let url = new URL(window.location.href);
        let params = new URLSearchParams(url.search);
        params.set('request', 'true');
        url.search = params.toString();
        // Use history.pushState to update the address bar without reloading the page
        history.pushState(history.state, '', url);
        // Follow link.
        window.location.href = event.target.href;
    }
}
