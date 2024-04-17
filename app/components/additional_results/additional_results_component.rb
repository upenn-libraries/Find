# frozen_string_literal: true

# Namespace for component that renders results from sources other than the catalog
module AdditionalResults
  extend self

  def self.results_sources
    @results_sources ||= begin
      sources = Settings.additional_results_sources.keys.map(&:to_s)
      validate_sources(sources) if sources.any?
    end
  end

  private

  def validate_sources(sources)
    sources.select do |source|
      "AdditionalResults::Sources::#{source.camelcase}Component".safe_constantize
    end
  end

  # def validate_sources(sources)
  #   validated_sources = []
  #
  #   sources.each do |source|
  #     source_component = "AdditionalResults::Sources::#{source.camelcase}Component".safe_constantize
  #
  #     if source_component.nil?
  #       Rails.logger.error source_error_message(source)
  #     else
  #       validated_sources << source
  #     end
  #   end
  #
  #   validated_sources
  # end

  def source_error_message(source)
    "\n[ERROR]Unknown Additional Results source #{source} has been excluded from display.\n" \
      "\tSources must correspond to a constant in the AdditionalResults::Sources namespace.\n" \
      "\t(ex: results_source_name => AdditionalResults::Sources::ResultsSourceNameComponent)\n"
  end

  # Renders container for results from sources other than the catalog
  class AdditionalResultsComponent < ViewComponent::Base
    def initialize(query:, **options)
      @query = query
      @validated_sources = AdditionalResults.results_sources
      @classes = Array.wrap(options[:class])&.join(' ')
    end

    # @return [String] the display name for a results source
    def source_display_name(source)
      Settings.additional_results_sources[source]&.display_name || source.titleize
    end
  end
end
