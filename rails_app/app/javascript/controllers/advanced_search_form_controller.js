import { Controller } from "@hotwired/stimulus";

// attaches to Catalog::AdvancedSearchForm component
export default class extends Controller {
    // dispatch submit event on advanced search page form to other controllers listening
    submit(event) {
        this.dispatch("submit");
    }

    // remove blank formData entries during formData event to prevent blank search parameters in the request
    removeBlank(event) {
        const formData = event.formData;
        const entries = Array.from(formData.entries());

        for (const [name, value] of entries) {
            // Get clause parameter field value that corresponds to the entry
            const field = formData.get(name.replace("query", "field"));

            // Get clause parameter query value that corresponds to the entry
            const query = formData.get(name.replace("field", "query"));

            // Allow entries that correspond to "all_fields_advanced" search field to ensure we make a request to solr
            // when a search is submitted without any search fields filled in
            if (field === "all_fields_advanced") {
                continue;
            }
            // Delete entries if the corresponding clause parameter query value is blank
            if (query === "") {
                formData.delete(name);
            }
        }
    }
}
