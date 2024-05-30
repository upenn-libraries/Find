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

    addAnchorToUrl() {
        window.location.hash = 'request_item';
    }
}
