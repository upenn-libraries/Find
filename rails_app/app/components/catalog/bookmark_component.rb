# frozen_string_literal: true

module Catalog
  # Extend Blacklight v9.0 BookmarkComponent to allow us to customize the markup for usage on the show page
  class BookmarkComponent < Blacklight::Document::BookmarkComponent
    TOOLTIP_CONTENT_SELECTOR = "[data-checkboxsubmit-target='span']"
    TOOLTIP_REFRESH_ACTION = 'bookmark.blacklight@document->tooltip#refresh'

    def bookmark_label
      I18n.t(bookmarked? ? 'blacklight.search.bookmarks.present' : 'blacklight.search.bookmarks.absent')
    end

    def bookmark_label_options
      options = {
        class: "toggle-bookmark-label",
        data: bookmark_label_data,
        aria: { label: bookmark_label }
      }
      options[:tabindex] = "0" if bookmark_icon
      options
    end

    private

    def bookmark_label_data
      {
        checkboxsubmit_target: 'label',
        controller: 'tooltip',
        action: TOOLTIP_REFRESH_ACTION,
        tooltip_content_selector_value: TOOLTIP_CONTENT_SELECTOR,
        bs_title: bookmark_label
      }
    end
  end
end
