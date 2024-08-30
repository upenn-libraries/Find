# frozen_string_literal: true

module Catalog
  # Extend BL's v8.3.0@69373f202 BookmarkComponent to allow us to customize the markup for usage on the show page
  class BookmarkComponent < Blacklight::Document::BookmarkComponent; end
end
