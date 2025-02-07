# frozen_string_literal: true

module Discover
  # Render a logo for Discover Penn
  class LogoComponent < ViewComponent::Base
    renders_one :image, lambda { |src, **options|
      options[:class] = Array.wrap(options[:class])
      image_tag(src, **options)
    }

    def initialize(**logo_options)
      logo_options[:class] = Array.wrap(logo_options[:class])

      @href = logo_options.delete(:href)
      @logo_options = logo_options
    end

    def render?
      image?
    end

    # Render the logo wrapped in a link if provided, otherwise just render the logo
    def call
      return image unless linked_logo?

      link_to(@href, **@logo_options) do
        concat(image)
      end
    end

    private

    # Returns true if a link has been provided for the logo
    # @return [Boolean]
    def linked_logo?
      @href.present?
    end
  end
end
