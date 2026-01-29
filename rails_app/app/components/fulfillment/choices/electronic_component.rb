# frozen_string_literal: true

module Fulfillment
  module Choices
    # Electronic delivery component
    class ElectronicComponent < BaseComponent
      def delivery_value
        Fulfillment::Options::Deliverable::ELECTRONIC
      end
    end
  end
end
