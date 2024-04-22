# frozen_string_literal: true

module Account
  # renders a single fine
  class FineRowComponent < ViewComponent::Base
    attr_reader :fine

    def initialize(fine:)
      @fine = fine
    end

    # @return [String]
    def type
      fine.type['desc']
    end

    # @return [String]
    def title
      fine.title.titleize.squish
    end

    # @return [String]
    def created_at
      DateTime.parse(fine.creation_time).strftime('%m/%d/%Y')
    end

    # @return [String, nil]
    def last_transaction
      date = fine.transaction&.first&.fetch('transaction_time')

      return unless date

      DateTime.parse(date).strftime('%m/%d/%Y')
    end

    # @return [String]
    def original_amount
      number_to_currency(fine.original_amount)
    end

    # @return [String]
    def balance
      number_to_currency(fine.balance)
    end
  end
end
