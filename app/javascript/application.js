// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "popper";
import "bootstrap";
import Blacklight from "blacklight";

const events = [
  "turbo:fetch-request-error",
  "turbo:frame-missing",
  "turbo:frame-load",
  "turbo:frame-render",
  "turbo:before-frame-render",
  "turbo:load",
  "turbo:render",
  "turbo:before-stream-render",
  "turbo:before-render",
  "turbo:before-cache",
  "turbo:submit-end",
  "turbo:before-fetch-response",
  "turbo:before-fetch-request",
  "turbo:submit-start",
  "turbo:visit",
  "turbo:before-visit",
  "turbo:click",
];

events.forEach((e) => {
  addEventListener(e, () => {
    console.log(e);
  });
});
