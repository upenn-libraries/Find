# frozen_string_literal: true

module Discover
  # Controller actions for the university collection bento search page
  class DiscoverController < ApplicationController
    layout 'discover'

    before_action :validate_query

    # /discover
    def index
      respond_to do |format|
        format.html do
          render Discover::MainPageComponent.new(query: params[:q].to_s, count: params[:count],
                                                 render_pse: params[:no_pse] != 'true')
        end
      end
    end

    private

    def validate_query
      flash[:alert] = t('discover.empty_query') if params.key?(:q) && params[:q].blank?
    end
  end
end
