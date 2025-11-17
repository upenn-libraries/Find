# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    get 'login', to: 'login#index', as: :new_user_session
    post 'sign_out', to: 'devise/sessions#destroy'
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  scope :login do
    get '/', to: 'login#index', as: 'login'
    get 'alma', to: 'login#alma', as: 'alma_login'
  end

  authenticated do
    root to: 'catalog#index', as: 'authenticated_root'
  end

  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/'

  root to: 'catalog#index'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [], as: 'catalog', path: '/catalog', controller: 'catalog' do
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
      get 'holding/:holding_id/detail', to: 'inventory#physical_detail', as: :physical_detail
      get 'hathi_link', to: 'inventory#hathi_link', as: :hathi_link
    end
  end

  resources :bookmarks, except: %i[show new edit] do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  namespace :fulfillment do
    get 'options'
    get 'form'
  end

  resource 'account', only: %i[show], controller: 'account'
  namespace :account, as: nil do
    resource :settings, only: %i[show edit update], controller: 'settings'
    resources :requests, only: %i[index create]

    # In order to get the path helpers to end in `_request` we had to define the additional actions in this way.
    scope controller: :requests, path: 'requests' do
      get 'ill/new', action: :ill, as: 'ill_new_request'

      get ':system/:type/:id', action: :show, as: 'request',
                               constraints: { system: /(ill|ils)/, type: /(loan|hold|transaction)/ }
      patch 'ils/loan/renew_all', action: :renew_all, as: :ils_renew_all_request
      patch 'ils/loan/:id/renew', action: :renew, as: :ils_renew_request
      get 'ill/transaction/:id/download', action: :scan, controller: :download, as: :ill_download_request
      delete 'ils/hold/:id', action: :delete_hold, as: :ils_hold_request
      delete 'ill/transaction/:id', action: :delete_transaction, as: :ill_transaction_request
    end

    get 'shelf', to: 'requests#index' # Vanity route for viewing all "requests".
    get 'fines-and-fees', to: 'fines#index'
  end

  get ':library_code/info', to: 'library#info', controller: 'library', as: :library_info
  get 'additional_results/:source', to: 'additional_results#results', as: 'additional_results'
  post 'webhooks/alerts', to: 'alert_webhooks#listen'
  post 'alerts/dismiss', to: 'alert_dismiss#dismiss'

  if Settings.discover.enabled
    scope module: :discover do
      get '/collects', to: 'discover#index'
    end
    namespace :discover do
      get '/', to: 'discover#index'
      get ':source/results', to: 'search#results', as: 'search_results'
    end
  end

  if Settings.suggester.enabled
    namespace :suggester do
      get ':q', to: 'suggestions#show', constraints: { q: /.+/ }, format: false
    end
  end
end
