# frozen_string_literal: true

module Illiad
  # An Enumerable to use when retrieving multiple Illiad DisplayStatues
  class DisplayStatusSet
    include Enumerable

    attr_reader :display_statues

    # @param display_statues [Array]
    def initialize(display_statues:)
      @display_statues = display_statues.map { |req| Illiad::DisplayStatus.new(**req) }
    end

    def each(&)
      display_statues.each(&)
    end

    # Returns display status if one is available, otherwise returns original status.
    #
    # @return [String] display status
    def for(status)
      display_statues.find { |s| s.transaction_status == status }&.display_status || status
    end
  end
end
