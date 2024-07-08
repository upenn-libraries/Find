import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["addComments", "commentsArea"];
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
    this.commentsAreaTarget.classList.remove("d-none");
  }
}
