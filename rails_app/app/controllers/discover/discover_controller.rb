# frozen_string_literal: true

module Discover
  # Controller actions for the University-wide collection bento search page
  class DiscoverController < ApplicationController
    # This configured layout (app/views/layouts/discover.html.erb) replaces, but mostly attempts to recreate the layout
    # used by Blacklight pages (app/views/layouts/blacklight/base.html.erb). Our own layout is needed, for now, to
    # remove the Catalog-specific search bar area.
    layout 'discover'

    def index
      render 'discover/index'
    end

    def about
      render 'discover/about'
    end
  end
end
