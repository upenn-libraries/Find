# frozen_string_literal: true

# Base helper for application views
module ApplicationHelper
  # Render Subject heading values as facet field links
  # @param [Hash] options
  # @return [ActiveSupport::SafeBuffer]
  def render_subject_facet_links(options)
    safe_join_links(
      options[:value].map { |value|
        link_to value, search_catalog_path({ 'f[subject_facet]': value })
      }.sort
    )
  end

  # Render JSON array field of link hashes into <br> delimited HTML
  # @param [Hash] options
  # @return [ActiveSupport::SafeBuffer]
  def render_links_from_hash(options)
    # If the field is stored, it will be a JSON encoded string
    link_data = if options[:value].first.is_a? String
                  JSON.parse(options[:value].first, symbolize_names: true)
                else
                  options[:value]
                end
    safe_join_links(
      link_data.map do |link_info|
        link_to link_info[:link_text], link_info[:link_url]
      end
    )
  end

  # @param [Array<String>] links
  # @return [ActiveSupport::SafeBuffer]
  def safe_join_links(links)
    sanitize(
      links.join('<br/>'),
      tags: %w[a br], attributes: ['href']
    )
  end
end
