import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ['itemSelect', 'mmsIdField', 'requestItemButton', 'commentsArea', 'holdingSelect']

    holdingSelectChanged(event) {
        const holdingValue = event.target.value
        const mmsIdValue = this.mmsIdFieldTarget.value
        const url = `/requests/item_labels?mms_id=${mmsIdValue}&holding_id=${holdingValue}`

        this.itemSelectTarget.disabled = true;
        this.requestItemButtonTarget.disabled = true;

        if (holdingValue) {
            fetch(url)
                .then(response => response.json())
                .then(data => {
                    this.populateItemSelect(data);
                })
                .catch(error => {
                    console.error('Error:', error)
                    this.itemSelectTarget.disabled = false;
                })
        }
    }

   itemSelectChanged(event) {
        const mmsIdValue = this.mmsIdFieldTarget.value
        const holdingValue = this.holdingSelectTarget.value
        const itemValue = event.target.value
        const url = `/requests/options?mms_id=${mmsIdValue}&holding_id=${holdingValue}&item_pid=${itemValue}`
        const frame = document.getElementById('options_frame')

        frame.src = url
    }

    showCommentsArea(event) {
        event.preventDefault();
        event.target.classList.add('d-none')
        this.commentsAreaTarget.classList.remove('d-none')
    }

    populateItemSelect(data) {
        this.itemSelectTarget.innerHTML = '';
        data.forEach(item => {
            const optionElement = document.createElement('option');
            optionElement.textContent = item[0];
            optionElement.value = item[1];
            this.itemSelectTarget.appendChild(optionElement);
        });

        this.itemSelectTarget.disabled = data.length < 1;
        this.requestItemButtonTarget.disabled = false;
    }
}