# frozen_string_literal: true

module Discover
  # Render the collection bento-specific search area
  class SearchBarComponent < ViewComponent::Base
    # @param [ActionController::Parameters] params
    def initialize(params:)
      @params = params
    end
  end
end
