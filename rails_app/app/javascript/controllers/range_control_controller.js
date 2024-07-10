import { Controller } from "@hotwired/stimulus";

/** attaches to Find::AdvancedSearch::RangeControl component to support ranged searches
 on advanced search form
 */
export default class extends Controller {
    static targets = ["query", "start", "end"];

    // provide the hidden query control with the prepared value during the form's 'submit' event
    submit_range(event) {
        this.queryTarget.value = this.prepare();
    }

    // prepare the solr friendly search range value from the start and end input values
    prepare() {
        const wildcard = "*";
        const start = this.startTarget.value || wildcard;
        const end = this.endTarget.value || wildcard;

        return start === wildcard && end === wildcard ? "" : `[${start} TO ${end}]`;
    }
}