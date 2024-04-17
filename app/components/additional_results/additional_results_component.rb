# frozen_string_literal: true

# Namespace for component that renders results from sources other than the catalog
module AdditionalResults
  # Renders container for results from sources other than the catalog
  class AdditionalResultsComponent < ViewComponent::Base
    include AdditionalResults::SourcesHelper

    # @param query [String] the search term
    # @param options [Hash] options for the component
    # @option options [String] :class Class(es) to apply to the component template
    def initialize(query:, **options)
      @query = query
      @validated_sources = results_sources
      @classes = Array.wrap(options[:class])&.join(' ')
    end

    # @return [String] the display name for an additional results source, either
    #   explicitly as explicitly set in Settings.additional_results_sources or
    #   inferred from the source name
    def source_display_name(source)
      Settings.additional_results_sources[source]&.display_name || source.titleize
    end
  end
end
