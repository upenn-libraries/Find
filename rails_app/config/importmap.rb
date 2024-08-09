# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin '@github/auto-complete-element', to: 'https://cdn.skypack.dev/@github/auto-complete-element'
pin 'popper', to: 'popper.js', preload: true
pin 'bootstrap', to: 'bootstrap.min.js', preload: true
pin 'tom-select', preload: true # @2.3.1

# TODO: fix getAssetPath issue with components
# pin '@penn-libraries/web', to: "https://cdn.jsdelivr.net/npm/@penn-libraries/web@#{Settings.pennlibs_web_version}/loader/index.js"
