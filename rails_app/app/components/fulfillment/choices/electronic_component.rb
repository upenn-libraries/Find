# frozen_string_literal: true

module Fulfillment
  module Choices
    # Electronic delivery component
    class ElectronicComponent < BaseComponent
      def radio_label_content
        t('requests.form.options.scan.label')
      end

      def delivery_value
        Fulfillment::Options::Deliverable::ELECTRONIC
      end
    end
  end
end
