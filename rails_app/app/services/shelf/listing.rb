# frozen_string_literal: true

module Shelf
  # An object to wrap around a set of shelf entries. This class should contain logic to sort/order a set of entries.
  class Listing
    include Enumerable

    attr_reader :entries, :filters, :sort, :order

    # @param entries [Shelf::Listing]
    # @param filters [Array<Symbol>]
    # @param sort [Symbol]
    # @param order [Symbol]
    def initialize(entries, filters:, sort:, order:)
      @filters = filters
      @sort = sort
      @order = order
      @entries = filter_and_sort(entries)
    end

    def each(&)
      entries.each(&)
    end

    # Returns true if loans are present.
    def loans?
      entries.any?(&:ils_loan?)
    end

    private

    def filter_and_sort(entries)
      entries = remove_duplicate_entries(entries)
      entries = filter(entries)
      entries.sort_by! { |e| sorting_value(e) }
      entries.reverse! if descending_order? # Flip order if descending order requested
      entries
    end

    # Books from external libraries are checked out to patrons via Alma. In these cases, there is a record in Alma and
    # a record Illiad that represents the same transaction. In most cases our filtering of Illiad results removes
    # these duplicate entries, but in the case of Borrow Direct we show all Borrow Direct entries for the last ten days
    # and have to manually filter out any duplicate entries. This is because in Illiad we can't differentiate between
    # Borrow Direct request that are in transit and Borrow Direct requests that are completed.
    def remove_duplicate_entries(entries)
      # Extract the barcodes from all Alma holds and loans.
      barcodes = entries.filter_map { |e| e.barcode unless e.ill_transaction? }

      # Then remove the Illiad transaction that have a matching Alma loan or hold.
      entries.reject do |entry|
        next unless entry.ill_transaction?

        barcodes.include?(entry.borrow_direct_identifier)
      end
    end

    # valid filters :loans, :requests, :scans
    def filter(entries)
      entries.select do |entry|
        next true if filters.include?(:scans) && entry.ill_transaction? && entry.scan?
        next true if filters.include?(:loans) && entry.ils_loan?
        next true if filters.include?(:requests) && entry.ils_hold?
        next true if filters.include?(:requests) && entry.ill_transaction? && entry.loan?
      end
    end

    # When sorting by due date, some List Entry types don't have a due date, so we need to ensure they sort to the
    # bottom regardless of direction.
    # @param [ActiveSupport::TimeWithZone, String] element
    def sorting_value(element)
      return element.send(sort) unless sort.in?([Shelf::Service::DUE_DATE, Shelf::Service::LAST_UPDATED_AT])

      element.send(sort) || (descending_order? ? 400.years.ago : 400.years.since)
    end

    # @return [Boolean]
    def descending_order?
      order == Shelf::Service::DESCENDING
    end
  end
end
