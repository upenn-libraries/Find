# frozen_string_literal: true

module Discover
  # Render the collection bento site footer
  class FooterComponent < ViewComponent::Base
    renders_one :logo, 'Discover::LogoComponent'

    renders_many :links, lambda { |text, href, **options|
      link_to text, href, **options
    }

    def render?
      logo? || links?
    end
  end
end
