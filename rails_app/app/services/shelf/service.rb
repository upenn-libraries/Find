# frozen_string_literal: true

module Shelf
  # Service that returns all the items on a user's "shelf", which includes Alma holds, Alma loans and ILL transactions.
  class Service
    # Catch all for errors raised when making requests to Alma.
    class AlmaRequestError < StandardError; end

    # Catch all for errors raised when making requests to Illiad.
    class IlliadRequestError < StandardError; end
    ILS_REQUEST_LIMIT = 50
    FILTERS = %i[loans scans requests].freeze
    DESCENDING = :desc
    ASCENDING = :asc
    TITLE = :title
    LAST_UPDATED_BY = :last_updated_at
    DUE_DATE = :due_date
    SORTS = [LAST_UPDATED_BY, TITLE, DUE_DATE].freeze
    ORDERS = [ASCENDING, DESCENDING].freeze

    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    # Finds all entries. Entries can be sorted and filtered with the appropriate params.
    #
    # @param filters [Array] list of types of entries to include
    # @param sort [Symbol] field we should sort on
    # @param order [Symbol] direction of sorting
    # @return [Shelf::Listing]
    def find_all(filters: FILTERS, sort: LAST_UPDATED_BY, order: DESCENDING)
      # Doing some pre-filtering to avoid unnecessary API calls.
      entries = if filters.eql?([:scans])
                  ill_transactions
                elsif filters.eql?([:loans])
                  ils_loans
                else
                  ils_loans + ils_holds + ill_transactions
                end

      Listing.new(entries, filters: filters, sort: sort, order: order)
    end

    # Find specific transaction based on system, id, and type
    def find(system, type, id)
      send("#{system}_#{type}", id)
    end

    # Renews all eligible loans for user.
    #
    # @raise [Shelf::Service::AlmaRequestError] when there was an unexpected issue with request
    # @return [Array<Alma::RenewalResponse>] when request returns expected success or failure response
    def renew_all_loans
      renewable_loans = Alma::Loan.where_user(user_id).select(&:renewable?)
      renewable_loans.map { |loan| renew_loan(loan.loan_id) }
    rescue StandardError => e
      raise AlmaRequestError, e.message
    end

    # Renews loan for user.
    #
    # @raise [Shelf::Service::AlmaRequestError] when there was an unexpected issue with request
    # @return [Alma::RenewalResponse] when request returns expected success or failure response
    def renew_loan(loan_id)
      Alma::User.renew_loan({ user_id: user_id, loan_id: loan_id })
    rescue StandardError => e
      raise AlmaRequestError, e.message
    end

    # Cancels hold for user.
    #
    # @raise [Shelf::Service::AlmaRequestError] when unsuccessful
    # @return [nil] when successful
    def cancel_hold(hold_id)
      Alma::User.cancel_request({ user_id: user_id, request_id: hold_id })
    rescue StandardError => e
      raise AlmaRequestError, e.message
    end

    # Delete ILL scan request where the PDF is already available.
    #
    # We "delete" a scan request by moving the status to "Request Finished". This will
    # remove the transaction from the displaying in the Shelf.
    #
    # @raise [Shelf::Service::IlliadRequestError] when unsuccessful
    def delete_scan_transaction(id)
      entry = ill_transaction(id)

      # In order to "delete" a transaction, it must be a scan request where the status is "Delivered to Web".
      raise IlliadRequestError, 'Transaction cannot be deleted' if entry.blank? || !entry.pdf_available?

      Illiad::Request.route(id: entry.id, status: Entry::IllTransaction::Status::FINISHED)
    rescue StandardError => e
      raise IlliadRequestError, e.message
    end

    # Adding history entry to ILL transaction to mark that the user has viewed the PDF.
    #
    # @raise [Shelf::Service::IlliadRequestError] when unsuccessful
    def mark_pdf_viewed(id)
      entry = ill_transaction(id)

      # In order to mark a PDF as viewed, it must be a scan request where the status is "Delivered to Web".
      raise IlliadRequestError, 'Transaction does not have a PDF' unless entry.pdf_available?

      Illiad::Request.history(id: entry.id, entry: I18n.t('fulfillment.illiad.pdf_viewed'))
    rescue StandardError => e
      raise IlliadRequestError, e.message
    end

    private

    # Returns all Alma loans for the given user.
    #
    # Does not return renewable information because expanding the request to include renewable information
    # increases the wait time significantly.
    #
    # @raise [Shelf::Service::AlmaRequestError] when unsuccessful
    # @return [Array<Shelf::Entry::IlsLoan>] when successful
    def ils_loans
      offset = 0
      loans = []

      loop do
        response = Alma::Loan.where_user(user_id, { expand: '', offset: offset, limit: ILS_REQUEST_LIMIT })
        loans += response.map { |l| Entry::IlsLoan.new(l.response) }

        break if response.total_record_count == loans.count

        offset += ILS_REQUEST_LIMIT
      end

      loans
    rescue StandardError => e
      raise AlmaRequestError, e.message
    end

    # Returns all Alma holds for the given user
    #
    # @raise [Shelf::Service::AlmaRequestError] when unsuccessful
    # @return [Array<Shelf::Entry::IlsHold>] when successful
    def ils_holds
      offset = 0
      holds = []

      loop do
        response = Alma::UserRequest.where_user(
          user_id, { request_type: 'HOLD', offset: offset, limit: ILS_REQUEST_LIMIT }
        )
        holds += response.map { |l| Entry::IlsHold.new(l.response) }

        break if response.total_record_count == holds.count

        offset += ILS_REQUEST_LIMIT
      end

      holds
    rescue StandardError => e
      raise AlmaRequestError, e.message
    end

    # Returns all active ILL transactions for a user.
    #
    # @raise [Shelf::Service::IlliadRequestError] when unsuccessful
    # @return [Array<Shelf::Entry::IllTransaction>] when successful
    def ill_transactions
      # Because Illiad transactions are not removed when they are completed, we have to filter out the completed
      # requests as best as we can. Currently we are filtering out:
      #   - Cancelled requests that are older than 4 weeks.
      #   - All completed requests except BorrowDirect requests that less than 10 days old.
      #   - All requests that are checked out to customer.
      # rubocop:disable Layout/LineLength
      filter = [
        "(TransactionStatus eq '#{Entry::IllTransaction::Status::CANCELLED}' and TransactionDate ge datetime'#{2.weeks.ago.utc.iso8601}')",
        "(TransactionStatus eq '#{Entry::IllTransaction::Status::FINISHED}' and SystemID eq '#{Entry::IllTransaction::BD_SYSTEM_ID}' and TransactionDate ge datetime'#{10.days.ago.utc.iso8601}')",
        "(TransactionStatus ne '#{Entry::IllTransaction::Status::CHECKED_OUT}' and TransactionStatus ne '#{Entry::IllTransaction::Status::CANCELLED}' and TransactionStatus ne '#{Entry::IllTransaction::Status::FINISHED}')"
      ].join(' or ')
      # rubocop:enable Layout/LineLength

      Illiad::User.requests(user_id: user_id, filter: filter)
                  .map { |t| Entry::IllTransaction.new(t, illiad_display_statues) }
    rescue StandardError => e
      raise IlliadRequestError, e.message
    end

    # Look up Illiad transaction based on id.
    #
    # @raise [Shelf::Service::IlliadRequestError] when unsuccessful
    # @return [Shelf::Entry::IllTransaction] when successful
    def ill_transaction(id)
      request = Illiad::Request.find(id: id)
      raise IlliadRequestError, 'Transaction does not belong to user.' unless request.user == user_id

      Entry::IllTransaction.new(request, illiad_display_statues)
    rescue StandardError => e
      raise IlliadRequestError, e.message
    end

    # Look up Alma loan based on id.
    # @raise [Shelf::Service::AlmaRequestError] when unsuccessful
    # @return [Shelf::Entry::IlsLoan] when successful
    def ils_loan(id)
      Alma::User.find_loan({ user_id: user_id, loan_id: id })
                .then { |l| Entry::IlsLoan.new(l.response) }
    rescue StandardError => e
      raise AlmaRequestError, e.message
    end

    # Look up Alma hold based on id.
    #
    # @raise [Shelf::Service::AlmaRequestError] when unsuccessful
    # @return [Shelf::Entry::IlsHold] when successful
    def ils_hold(id)
      Alma::User.find_request({ user_id: user_id, request_id: id })
                .then { |h| Entry::IlsHold.new(h.response) }
    rescue StandardError => e
      raise AlmaRequestError, e.message
    end

    # Return all Illiad display statues
    #
    # @return [Illiad::DisplayStatusSet]
    def illiad_display_statues
      @illiad_display_statues ||= Illiad::DisplayStatus.find_all
    end
  end
end
