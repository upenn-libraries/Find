# frozen_string_literal: true

module Find
  # Builds array of links from link hashes
  class LinkToProcessor < Blacklight::Rendering::AbstractStep
    include ActionView::Helpers::UrlHelper

    def render
      return next_step(values) if values.blank?
      return next_step(values) unless link_hash?(values.first)

      links = values.filter_map do |value|
        link_to(value[:link_text], value[:link_url])
      end

      next_step links
    end

    private

    # @param [String] value
    def link_hash?(value)
      value.instance_of?(Hash) && value.key?(:link_text) && value.key?(:link_url)
    end
  end
end
