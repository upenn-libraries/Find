# frozen_string_literal: true

# Helper for Catalog-related functionality
module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # @param document [SolrDocument]
  # @return [ActiveSupport::SafeBuffer]
  def as_badge(document)
    tag.span(document[:value].first, class: %w[badge bg-secondary])
  end
end
