# frozen_string_literal: true

module CreatorSuggest
  class Component < Blacklight::Component
    include Turbo::FramesHelper

    def initialize(results:)
      @results = results
    end

    attr_reader :results
  end
end
