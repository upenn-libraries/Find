# frozen_string_literal: true

module Account
  # Component that renders the status for a Shelf::Entry.
  class ShelfStatusComponent < ViewComponent::Base
    attr_reader :entry

    # @param entry [Shelf::Entry]
    def initialize(entry)
      @entry = entry
    end

    # Style classes to add based on the status being displayed
    def classes
      if entry.ils_hold? && entry.on_hold_shelf?
        ['shelf-status--info']
      elsif entry.ils_loan? && (Time.current > entry.due_date)
        ['shelf-status--danger']
      elsif entry.ils_loan? && (Time.current >= entry.due_date.ago(5.days))
        ['shelf-status--info']
      end
    end

    def call
      tag.span(entry.status, class: classes)
    end
  end
end
