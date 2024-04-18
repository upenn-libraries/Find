# frozen_string_literal: true

module AdditionalResults
  # Helper methods for interacting with additional results sources
  module SourceHelper
    include Rails.application.routes.url_helpers

    # @param source [String] the results source id
    # @return [String] the display name for an additional results source, either
    #   explicitly as explicitly set in Settings.additional_results_sources or
    #   inferred from the source name
    def source_display_name(source)
      Settings.additional_results_sources[source]&.display_name || source.titleize
    end

    # @param source [String] the results source id
    # @param query [String] the search term
    # @return [String] the src path for the source's turbo frame component
    def source_results_path(source:, query:)
      additional_results_catalog_path(params: { source_id: source, q: query })
    end

    # @param source [String] the results source id
    # @return [Object] the component class corresponding to the source id, if present
    def source_component(source)
      "AdditionalResults::Sources::#{source.camelcase}Component".safe_constantize
    end

    # @param source [String] the results source id
    # @return [Boolean] true if a corresponding component exists for the source id
    def valid_source?(source)
      source_component(source).present?
    end
  end
end
