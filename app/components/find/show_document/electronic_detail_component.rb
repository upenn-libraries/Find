# frozen_string_literal: true

module Find
  module ShowDocument
    # Component for rendering electronic detail information (notes)
    class ElectronicDetailComponent < ViewComponent::Base
      attr_accessor :detail

      delegate :notes, to: :detail

      def initialize(detail:)
        @detail = detail
      end

      def formatted_notes
        notes.join.html_safe
      end
    end
  end
end
