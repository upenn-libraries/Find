# frozen_string_literal: true

module Account
  # Component that renders filters and sorting options for a Shelf::Listing.
  class ShelfListingFiltersComponent < ViewComponent::Base
    # @param listing [Shelf::Listing]
    def initialize(listing)
      @listing = listing
    end

    private

    def filter_checkbox(value)
      checked = @listing.filters.include?(value)
      label = value.to_s.titlecase

      tag.div(class: 'form-check') do
        tag.label(class: 'd-inline-block p-1') do
          check_box_tag('filters[]', value, checked, class: 'form-check-input') + label
        end
      end
    end

    def sort_radio(sort, order)
      checked = @listing.order == order && @listing.sort == sort
      label = I18n.t("account.shelf.refine.sort.options.#{sort}.#{order}")

      tag.div(class: 'form-check') do
        tag.label(class: 'd-inline-block p-1') do
          radio_button_tag(:sort, "#{sort}_#{order}", checked, class: 'form-check-input') + label
        end
      end
    end
  end
end
