# frozen_string_literal: true

module AdditionalResults
  # Renders results from sources other than the catalog
  class ResultsSourceComponent < ViewComponent::Base
    include AdditionalResults::SourceHelper
    include Turbo::FramesHelper

    attr_reader :source

    # @param query [String] the search term
    # @param options [Hash] options for the component
    # @option options [String] :class Class(es) to apply to the component template
    def initialize(source_id, **options)
      @source = source_id
      @classes = Array.wrap(options[:class])&.join(' ')
    end

    # @return [Boolean] true if the source id has a corresponding component class
    def render?
      valid_source?(source)
    end

    # @return [String] the component to render in the additional results turbo frame
    def call
      turbo_frame_tag "additional-results-source__#{source}" do
        render source_component(source).new(query: params[:q], class: @classes)
      end
    end
  end
end
