# frozen_string_literal: true

module Illiad
  # An Enumerable to use when retrieving multiple Illiad DisplayStatues
  class DisplayStatusSet
    include Enumerable

    attr_reader :display_statuses

    # @param display_statuses [Array]
    def initialize(display_statuses:)
      @display_statuses = display_statuses.map { |req| Illiad::DisplayStatus.new(**req) }
    end

    def each(&)
      display_statuses.each(&)
    end

    # Returns display status if one is available, otherwise returns original status.
    #
    # @return [String] display status
    def display_for(status)
      display_statuses.find { |s| s.transaction_status == status }&.display_status || status
    end
  end
end
