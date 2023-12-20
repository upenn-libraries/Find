# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
pin '@github/auto-complete-element', to: 'https://cdn.skypack.dev/@github/auto-complete-element'
pin '@popperjs/core', to: 'https://ga.jspm.io/npm:@popperjs/core@2.11.6/dist/umd/popper.min.js'
pin 'bootstrap', to: 'https://ga.jspm.io/npm:bootstrap@5.2.2/dist/js/bootstrap.js'
# TODO: fix getAssetPath issue with components
# pin '@penn-libraries/web', to: "https://cdn.jsdelivr.net/npm/@penn-libraries/web@#{Settings.pennlibs_web_version}/loader/index.js"
