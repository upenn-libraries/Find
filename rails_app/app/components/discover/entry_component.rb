# frozen_string_literal: true

module Discover
  # Renders a single Discover::Entry object
  class EntryComponent < ViewComponent::Base
    attr_reader :presenter

    delegate(*Discover::Entry::BasePresenter::DISPLAY_TERMS, to: :presenter)

    # @param [Discover::Entry] entry
    # @param [string] source
    def initialize(entry:, source:)
      @presenter = create_presenter(entry: entry, source: source)
    end

    # @param [Hash] args
    # @option args [Discover::Entry] :entry
    # @option args [String] :source
    def create_presenter(**args)
      case args[:source]
      when 'museum'
        Discover::Entry::MuseumPresenter.new(**args)
      when 'art_collection'
        Discover::Entry::ArtCollectionPresenter.new(**args)
      else
        Discover::Entry::BasePresenter.new(**args)
      end
    end
  end
end
