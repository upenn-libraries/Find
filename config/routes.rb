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
    member do
      get 'librarian_view'
    end

    concerns :exportable

    member do
      get 'inventory'
    end
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  post 'webhooks/alerts', to: 'alert_webhooks#listen'
end
