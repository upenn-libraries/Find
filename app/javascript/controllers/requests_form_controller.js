import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        'itemSelect', 'mmsIdField', 'holdingIdField', 'commentsArea',
        'optionsFrame', 'optionsLoadingTemplate'
    ]

    itemSelectChanged(event) {
        const mmsIdValue = this.mmsIdFieldTarget.value
        const holdingValue = this.holdingIdFieldTarget.value
        const itemValue = event.target.value
        const url = `/account/requests/options?mms_id=${mmsIdValue}&holding_id=${holdingValue}&item_pid=${itemValue}`

        this.optionsFrameTarget.src = url
        this.optionsFrameTarget.innerHTML = this.optionsLoadingTemplateTarget.innerHTML
    }

    showCommentsArea(event) {
        event.preventDefault();
        event.target.classList.add('d-none')
        this.commentsAreaTarget.classList.remove('d-none')
    }
}