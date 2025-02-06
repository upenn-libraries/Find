# frozen_string_literal: true

module Discover
  # Render the Discover Penn-specific search area
  class SearchBarComponent < ViewComponent::Base
    # @param [ActionController::Parameters] params
    def initialize(params:)
      @params = params
    end

    # Determines whether or not the search bar should receive focus. If no query term is present, it should.
    # @return [Boolean]
    def autofocus?
      params[:q].blank?
    end
  end
end
