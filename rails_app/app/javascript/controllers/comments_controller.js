import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["commentsArea", "addCommentsButton", "hideCommentsButton"];

  // Display or remove comment box.
  displayComments(value) {
    if (value) {
      this.element.classList.remove("d-none");
    } else {
      this.element.classList.add("d-none");
    }
  }

  showCommentsArea(event) {
    event.preventDefault();
    event.target.classList.add("d-none");
    this.hideCommentsButtonTarget.classList.remove("d-none");
    this.commentsAreaTarget.classList.remove("d-none");
  }

  hideCommentsArea(event) {
    event.preventDefault();
    event.target.classList.add("d-none");
    this.addCommentsButtonTarget.classList.remove("d-none");
    this.commentsAreaTarget.classList.add("d-none");
  }
}
