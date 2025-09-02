# frozen_string_literal: true

module AdditionalResults
  # Helper methods for interacting with additional results sources
  module SourceHelper
    # @param source [String] the results source id
    # @return [String] the display name for an additional results source, either
    #   as explicitly set in Settings.additional_results_sources, defined in a
    #   source's display_name method, or inferred from the source name
    def display_name(source)
      if I18n.exists?("additional_results.#{source}.display_name")
        I18n.t("additional_results.#{source}.display_name")
      else
        source.titleize
      end
    end

    # @param source [String] the results source id
    # @param query [String] the search term
    # @return [String] the src path for the source's turbo frame component
    def results_path(source:, query:)
      additional_results_path(source, q: query)
    end

    # @param source [String] the results source id
    # @return [Class, nil] the component class corresponding to the source ID
    #   if defined under AdditionalResults::Sources::<SourceName>Component, or nil
    def component(source)
      "AdditionalResults::Sources::#{source.camelcase}Component".safe_constantize
    end

    # @param source [String] the results source id
    # @return [String] the id for the source's turbo frame
    def turbo_id(source)
      I18n.t('additional_results.turbo_frame_id', source: source)
    end

    # @param source [String] the results source id
    # @return [Boolean] true if a corresponding component exists for the source id
    def valid?(source)
      component(source).present?
    end
  end
end
