# frozen_string_literal: true

# One step in a breadcrumb path. A crumb with no href is the page you are on, so it renders as text
# and announces itself as the current page.
class BreadcrumbComponent < ViewComponent::Base
  # @param href [String, nil] leave it out for the page you are on
  # @param active [Boolean] whether this is the page you are on; follows href unless you say otherwise
  def initialize(href: nil, active: href.blank?, **options)
    @href = href.presence
    @options = options

    @options[:class] = Array.wrap(@options[:class]).append('pl-crumb')
    @options['aria-current'] = 'page' if active
  end

  def call
    tag.li(**@options) do
      @href ? tag.a(href: @href) { content } : content
    end
  end
end
