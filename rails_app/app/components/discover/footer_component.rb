# frozen_string_literal: true

module Discover
  # Render the Discover Penn site footer
  class FooterComponent < ViewComponent::Base
    renders_one :logo, lambda { |src, **options|
      options[:class] = Array.wrap(options[:class])
      image_tag src, **options
    }

    renders_many :links, lambda { |text, href, **options|
      options[:class] = Array.wrap(options[:class])
      link_to text, href, **options
    }

    # @return [Boolean]
    def logo?
      logo.present?
    end

    # @return [Boolean]
    def links?
      links.present?
    end
  end
end
