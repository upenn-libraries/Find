# frozen_string_literal: true

module Discover
  # Renders a single Discover::Entry object
  class EntryComponent < ViewComponent::Base
    attr_reader :presenter

    delegate(*Discover::Entry::BasePresenter::DISPLAY_TERMS, to: :presenter)

    # @param entry [Discover::Entry]
    # @param source [string]
    def initialize(entry:, source:)
      @presenter = create_presenter(entry: entry, source: source)
    end

    # @param args [Hash]
    # @option args [String] :source
    # @return [Discover::Entry::BasePresenter]
    def create_presenter(**args)
      case args[:source]&.to_sym
      when Configuration::PSE::Museum::SOURCE
        Discover::Entry::MuseumPresenter.new(**args)
      when Configuration::PSE::ArtCollection::SOURCE
        Discover::Entry::ArtCollectionPresenter.new(**args)
      else
        Discover::Entry::BasePresenter.new(**args)
      end
    end
  end
end
