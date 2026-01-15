# frozen_string_literal: true

module Fulfillment
  module Choices
    # Wharton DocDel component logic
    class DocdelComponent < BaseComponent
      def radio_label_content
        t('requests.form.options.docdel.label')
      end

      def delivery_value
        Fulfillment::Options::Deliverable::DOCDEL
      end
    end
  end
end
