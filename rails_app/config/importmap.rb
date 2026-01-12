# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
# TODO: load BS and popper.js from CDN for simplicity
pin '@popperjs/core', to: 'https://unpkg.com/@popperjs/core@2.11.8/dist/esm/index.js', preload: true
pin 'bootstrap', to: 'https://ga.jspm.io/npm:bootstrap@5.3.8/dist/js/bootstrap.esm.js', preload: true
pin 'tom-select', preload: true # @2.3.1

# TODO: fix getAssetPath issue with components
# pin '@penn-libraries/web', to: "https://cdn.jsdelivr.net/npm/@penn-libraries/web@#{Settings.pennlibs_web_version}/loader/index.js"
