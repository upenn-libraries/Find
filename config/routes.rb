# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    post 'sign_out', to: 'devise/sessions#destroy'
  end

  scope :login do
    get '/', to: 'login#index', as: 'login'
    get 'alma', to: 'login#alma', as: 'alma_login'
  end

  authenticated do
    root to: 'catalog#index', as: 'authenticated_root'
  end

  mount Blacklight::Engine => '/'
  root to: 'catalog#index'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable

    get 'databases', to: 'catalog#databases'
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable

    member do
      get 'staff_view'
    end
  end

  resources :inventory, only: [] do
    member do
      get 'brief'
      get 'portfolio/:pid/collection/:cid/detail', to: 'inventory#electronic_detail', as: :electronic_detail
    end
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resource 'account', only: %i[show], controller: 'account'
  namespace :account, as: nil do
    resource :settings, only: %i[show edit update], controller: 'settings'
    resources :requests, only: %i[index new create]

    # In order to get the path helpers to end in `_request` we had to define the additional action in this way.
    scope controller: :requests, path: 'requests' do
      get 'ill/new', action: 'ill', to: :ill_new, as: 'ill_new_request'
      get ':system/:id', action: 'show', to: :show, as: 'request', constraints: { system: /(ill|ils)/ }
      patch 'ils/:id/renew', action: 'renew', to: :renew, as: :ils_renew_request
      delete 'ils/:id', action: 'delete', to: :delete, as: :ils_request
    end

    get 'shelf', to: 'requests#index' # Vanity route for viewing all "requests".
    get 'fines-and-fees', to: 'fines#index'
  end

  post 'webhooks/alerts', to: 'alert_webhooks#listen'
end
