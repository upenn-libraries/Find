# frozen_string_literal: true

module Hathi
  # Hathi link component
  class HathiComponent < ViewComponent::Base
    attr_accessor :identifiers

    def initialize(document:)
      @identifiers = document.identifiers
      # service should return the full hathi record instead of just the URL
      @service = Hathi::Service.new(identifiers: identifiers)
    end

    def render?
      # is the record present?
    end

    def call
      content_tag(:p) do
        Hathi::Service.new(identifiers: identifiers).link
      end
    end
  end
end
