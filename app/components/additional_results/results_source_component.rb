# frozen_string_literal: true

module AdditionalResults
  # Renders results from sources other than the catalog
  class ResultsSourceComponent < ViewComponent::Base
    include AdditionalResults::SourceHelper

    attr_reader :source

    # @param query [String] the search term
    # @param options [Hash] options for the component
    # @option options [String] :class Class(es) to apply to the component template
    def initialize(source_id, **options)
      @source = source_id
      @options = options
    end

    # @return [Boolean] true if the source id has a corresponding component class
    def render?
      valid_source?(source)
    end

    # @return [String] the component to render in the additional results turbo frame
    def call
      content_tag 'turbo-frame', id: "additional-results-source__#{source}" do
        render source_component(source).new(query: params[:q], **@options)
      end
    end
  end
end
