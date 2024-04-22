# frozen_string_literal: true

module AdditionalResults
  # Renders results from sources other than the catalog
  class ResultsSourceComponent < ViewComponent::Base
    include Turbo::FramesHelper
    include AdditionalResults::SourceHelper

    attr_reader :source

    # @param source [String] the results source from which to render results
    # @param options [Hash] options for the component
    # @option options [String] :class class(es) to apply to the component template
    def initialize(source, **options)
      @source = source
      @classes = Array.wrap(options[:class])&.join(' ')
    end

    # @return [Boolean] true if the source id has a corresponding component class
    def render?
      valid?(source)
    end

    # @return [String] the component to render in the additional results turbo frame
    def call
      turbo_frame_tag turbo_id(source) do
        render component(source).new(query: params[:q], class: @classes)
      end
    end
  end
end
