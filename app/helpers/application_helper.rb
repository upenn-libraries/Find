# frozen_string_literal: true

# Base helper for application views
module ApplicationHelper
  # Render JSON array field of link hashes into <br> delimited HTML
  # @param [Hash] options
  # @return [String]
  def render_as_links(options)
    links = JSON.parse(options[:value].first)
    link_html = links.map { |link_info|
      link_to link_info['link_text'], link_info['link_url']
    }.join('<br/>')
    sanitize(link_html, tags: %w[a br], attributes: ['href'])
  end
end
