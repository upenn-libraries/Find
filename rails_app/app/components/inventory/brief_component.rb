# frozen_string_literal: true

module Inventory
  # Component that renders a set of Inventory entries for use in in filling-in a Turbo Frame.
  class BriefComponent < ViewComponent::Base
    attr_reader :document, :entries

    # @param document[SolrDocument]
    def initialize(document:)
      @document = document
      @entries = document.brief_inventory
    end
  end
end
