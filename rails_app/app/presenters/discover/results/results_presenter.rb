#  frozen_string_literal: true

module Discover
  class Results
    # Derives shared HTML attribute values shared between the ResultsSkeleton and Results components
    class ResultsPresenter
      ICON_CLASS_MAPPINGS = {
        Discover::Configuration::Blacklight::Find::SOURCE => %w[bi bi-book],
        Discover::Configuration::Blacklight::FindingAids::SOURCE => %w[bi bi-archive],
        Discover::Configuration::PSE::Museum::SOURCE => %w[card-icon discover-icon discover-icon-museum],
        Discover::Configuration::Database::ArtCollection::SOURCE => %w[bi bi-brush]
      }.freeze

      VALUES = %i[id turbo_frame_id results_button_id label icon_classes source results_button_id].freeze

      attr_reader :source, :results

      # @param source [String, Symbol]
      def initialize(source:)
        @source = source.to_s
      end

      # @return [String]
      def id
        label.downcase.split(' ').join('-')
      end

      # @return [String]
      def turbo_frame_id
        "#{id}-turbo-frame"
      end

      # @return [String]
      def results_button_id
        "#{id}-results-button"
      end

      # @return [String]
      def label
        I18n.t("discover.results.source.#{source}.label")
      end

      # @return [Array<String>]
      def icon_classes
        ICON_CLASS_MAPPINGS.fetch(source.to_sym, [])
      end
    end
  end
end
