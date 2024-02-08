// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import bootstrap from "bootstrap"
import Blacklight from "blacklight"

function FocusOnFindSearchBox(event) {
  console.log('active', document.activeElement)

  if (event.key === '/') {
    
  }
}

document.addEventListener('keydown', FocusOnFindSearchBox);