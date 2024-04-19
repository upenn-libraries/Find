import {Controller} from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ['commentsArea']

    showCommentsArea(event) {
        event.preventDefault();
        event.target.classList.add('d-none')
        this.commentsAreaTarget.classList.remove('d-none')
    }
}