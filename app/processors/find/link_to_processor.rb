# frozen_string_literal: true

module Find
  # Builds array of links from link hashes
  class LinkToProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Helpers::TextHelper

    def render
      return next_step(values) if values.blank?
      return next_step(values) unless link_hash?(values.first)

      joined = values.filter_map do |value|
        content_tag(:a, value[:link_text], href: value[:link_url])
      end

      next_step(joined)
    end

    private

    # @param [String] value
    def link_hash?(value)
      value.instance_of?(Hash) && value.key?(:link_text) && value.key?(:link_url)
    end
  end
end
