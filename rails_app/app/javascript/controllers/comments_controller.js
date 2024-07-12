import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["addComments", "commentsArea", "addCommentsButton", "hideCommentsButton"];
  COMMENT_OPTIONS = ["pickup", "ill_pickup", "mail", "office"];

  toggleComments({ detail: { option_value } }) {
    if (this.COMMENT_OPTIONS.includes(option_value)) {
      this.addCommentsTarget.classList.remove("d-none");
    } else {
      this.addCommentsTarget.classList.add("d-none");
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
