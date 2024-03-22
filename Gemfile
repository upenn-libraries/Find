# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

gem 'alma'
gem 'blacklight', '~> 8.0'
gem 'bootsnap', require: false
gem 'bootstrap', '~> 5.1'
gem 'config'
gem 'devise'
gem 'devise-guests', '~> 0.8'
gem 'faraday'
gem 'faraday-retry'
gem 'importmap-rails'
gem 'marc'
gem 'mini_racer'
gem 'omniauth'
gem 'omniauth-rails_csrf_protection'
gem 'omniauth-saml'
gem 'pennmarc', '~> 1'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'put'
gem 'rails', '~> 7.0.8'
gem 'rsolr'
gem 'sassc-rails'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
gem 'upennlib-rubocop', require: false
gem 'view_component', '~> 2.66'

group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails', '~> 6.0.0'
end

group :development do
  gem 'web-console'
end

group :test do
  gem 'capybara'
  gem 'cuprite'
end
