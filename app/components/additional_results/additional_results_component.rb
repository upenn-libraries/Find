# frozen_string_literal: true

# Namespace for component that renders results from sources other than the catalog
module AdditionalResults
  # Renders container for results from sources other than the catalog
  class AdditionalResultsComponent < ViewComponent::Base
    include AdditionalResults::SourcesHelper

    def initialize(query:, **options)
      @query = query
      @validated_sources = results_sources
      @classes = Array.wrap(options[:class])&.join(' ')
    end

    # @return [String] the display name for a results source
    def source_display_name(source)
      Settings.additional_results_sources[source]&.display_name || source.titleize
    end
  end
end
