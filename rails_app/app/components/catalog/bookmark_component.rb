# frozen_string_literal: true

module Catalog
  # Extend BL's v8.12.2 BookmarkComponent to allow us to customize the markup for usage on the show page
  class BookmarkComponent < Blacklight::Document::BookmarkComponent; end
end
