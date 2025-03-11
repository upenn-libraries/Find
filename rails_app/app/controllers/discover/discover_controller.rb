# frozen_string_literal: true

module Discover
  # Controller actions for the university collection bento search page
  class DiscoverController < ApplicationController
    layout 'discover'

    before_action :validate_query

    # /discover
    def index
      respond_to do |format|
        format.html { render Discover::MainPageComponent.new params: params }
      end
    end

    private

    def validate_query
      flash[:alert] = t('discover.empty_query') if params[:query].blank?
    end
  end
end
