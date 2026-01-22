# frozen_string_literal: true

module Catalog
  # Renders meta description tag with content from the SolrDocument
  class MetaDescriptionComponent < ViewComponent::Base
    attr_reader :document

    # @param document [SolrDocument]
    def initialize(document:)
      @document = document
    end

    # @return [String, nil]
    def description
      return unless document?

      @description ||= document.description
    end

    # @return [Boolean]
    def render?
      document? && description?
    end

    def call
      tag.meta(name: 'description', content: description)
    end

    private

    # @return [Boolean]
    def document?
      document.present?
    end

    # @return [Boolean]
    def description?
      description.present?
    end
  end
end
