# frozen_string_literal: true

module Shelf
  # An object to wrap around a set of shelf entries. This class should contain logic to sort/order a set of entries.
  class Listing
    include Enumerable

    attr_reader :entries

    def initialize(entries)
      @entries = filter_duplicate_entries(entries).sort_by(&:last_updated_at).reverse! # Sorting by last updated at.
    end

    def each(&)
      entries.each(&)
    end

    private

    # Books from external libraries are checked out to patrons via Alma. In these cases, there is a record in Alma and
    # a record Illiad that represents the same transaction. In most cases our filtering of Illiad results removes
    # these duplicate entries, but in the case of Borrow Direct we show all Borrow Direct entries for the last ten days
    # and have to manually filter out any duplicate entries. This is because in Illiad we can't differentiate between
    # Borrow Direct request that are in transit and Borrow Direct requests that are completed.
    def filter_duplicate_entries(entries)
      # Extract the barcodes from all Alma holds and loans.
      barcodes = entries.filter_map { |e| e.barcode unless e.ill_transaction? }

      # Then remove the Illiad transaction that have a matching Alma loan or hold.
      entries.reject do |entry|
        next unless entry.ill_transaction?

        barcodes.include?(entry.borrow_direct_identifier)
      end
    end
  end
end
