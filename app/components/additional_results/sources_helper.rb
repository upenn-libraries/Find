# frozen_string_literal: true

module AdditionalResults
  # Helper for retrieving validated additional results sources
  module SourcesHelper
    def results_sources
      @results_sources ||= begin
        sources = Settings.additional_results_sources.keys.map(&:to_s)
        validate_sources(sources) if sources.any?
      end
    end

    private

    def validate_sources(sources)
      sources.select do |source|
        component = "AdditionalResults::Sources::#{source.camelcase}Component"
        if component.safe_constantize
          true
        else
          # @todo Notify with Honeybadger
          Rails.logger.error source_error_message(source)
          false
        end
      end
    end

    def source_error_message(source)
      "\n[ERROR]Unknown Additional Results source #{source} has been excluded from display.\n" \
        "\tSources must correspond to a constant in the AdditionalResults::Sources namespace.\n" \
        "\t(ex: results_source_name => AdditionalResults::Sources::ResultsSourceNameComponent)\n"
    end
  end
end
