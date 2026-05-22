# frozen_string_literal: true

module Fulfillment
  module Choices
    # Wharton DocDel component logic
    class DocdelComponent < BaseComponent
      def delivery_value
        Fulfillment::Options::Deliverable::DOCDEL
      end
    end
  end
end
