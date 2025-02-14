# frozen_string_literal: true

module Discover
  # Placeholder component that renders upon initial page load and fetches results turbo-frame
  class ResultsSkeletonComponent < ViewComponent::Base
    attr_reader :source, :query, :disabled, :message

    # @param [String] source
    # @param [String] query
    # @param [String] message
    # @param [Boolean] disabled
    def initialize(source:, message:, query: '', disabled: false)
      @source = source
      @query = query
      @disabled = disabled
      @message = message
    end
  end
end
