// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import bootstrap from "bootstrap"
import Blacklight from "blacklight"
import { defineCustomElements } from '@penn-libraries/web'

// Load HTML Web Components from @penn-libraries/web
defineCustomElements(window);