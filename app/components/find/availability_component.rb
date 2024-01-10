# frozen_string_literal: true

module Find
  # Component that displays a records availability information.
  class AvailabilityComponent < Blacklight::Component
    # @param document [SolrDocument] record
    # @param brief [TrueClass|FalseClass] displays most important holding information, used in search results
    # @param lazy [TrueClass|FalseClass] lazy loads availability information using turbo-frames
    def initialize(document:, brief: false, lazy: false)
      @document = document
      @brief = brief
      @lazy = lazy
    end
  end
end
