# frozen_string_literal: true

# Component to create breadcrumbs.
class BreadcrumbsComponent < ViewComponent::Base
  renders_many :breadcrumbs, BreadcrumbComponent

  def initialize(**options)
    @options = options

    @options[:class] = Array.wrap(@options[:class])
  end

  def render?
    breadcrumbs.any?
  end

  def call
    tag.nav('aria-label': 'breadcrumb', **@options) do
      tag.ol(class: 'breadcrumb') { safe_join(breadcrumbs) }
    end
  end
end
