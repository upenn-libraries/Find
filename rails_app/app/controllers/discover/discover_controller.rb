# frozen_string_literal: true

module Discover
  # Controller actions for the university collection bento search page
  class DiscoverController < ApplicationController
    layout 'discover'

    # /discover
    def index
      # @search_params = params[:q]
      respond_to do |format|
        format.html { render Discover::MainPageComponent.new params: params }
      end
    end
  end
end
