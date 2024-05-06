# frozen_string_literal: true

module Find
  module Breadcrumbs
    # Component to create a section of a breadcrumb path.
    class BreadcrumbComponent < ViewComponent::Base
      def initialize(href: nil, active: false, **options)
        @href = href
        @options = options

        @options[:class] = Array.wrap(@options[:class]).append('breadcrumb-item')
        @options[:class] << 'active' if active
        @options['aria-current'] = 'page' if active
      end

      def call
        tag.li(**@options) do
          if @href
            tag.a(href: @href) { content }
          else
            content
          end
        end
      end
    end
  end
end
