# frozen_string_literal: true

module Discover
  # Controller actions for the university collection bento search page
  class DiscoverController < ApplicationController
    layout 'discover'

    # /discover
    def index
      @search_params = params[:q]
    end
  end
end
