#  frozen_string_literal: true

module Discover
  class Record
    # Prepares museum record values for display
    class MuseumPresenter < BasePresenter
      # @return [String, nil]
      def title
        record.title.first&.split('|')&.first
      end

      # @return [String, nil]
      def location
        record.location&.first&.split('|')&.last
      end
    end
  end
end
