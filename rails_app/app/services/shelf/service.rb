# frozen_string_literal: true

module Shelf
  # Service that returns all the items on a user's "shelf", which includes Alma holds, Alma loads and ILL transactions.
  class Service
    # Catch all for errors raised when making requests to Alma.
    class AlmaRequestError < StandardError; end

    # Catch all for errors raised when making requests to Illiad.
    class IlliadRequestError < StandardError; end

    attr_reader :user_id

    def initialize(user_id)
      @user_id = user_id
    end

    # TODO: Allow filtering and sorting.
    def find_all
      Listing.new(ils_loans + ils_holds + ill_transactions)
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

    private

    # Returns all Alma loans for the given user.
    #
    # Does not return renewable information because expanding the request to include renewable information
    # increases the wait time significantly.
    #
    # TODO: iterate through and grab all loans if there are more than 100
    # @raise [Shelf::Service::AlmaRequestError] when unsuccessful
    # @return [Array<Shelf::Entry::IlsLoan>] when successful
    def ils_loans
      Alma::Loan.where_user(user_id, { expand: '' })
                .map { |l| Entry::IlsLoan.new(l.response) }
    rescue StandardError => e
      raise AlmaRequestError, e.message
    end

    # Returns all Alma holds for the given user
    #
    # TODO: need to iterate thought all the holds if there are more than 100
    # @raise [Shelf::Service::AlmaRequestError] when unsuccessful
    # @return [Array<Shelf::Entry::IlsHold>] when successful
    def ils_holds
      Alma::UserRequest.where_user(user_id, { request_type: 'HOLD' })
                       .map { |l| Entry::IlsHold.new(l.response) }
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
        "(TransactionStatus eq 'Cancelled by ILL Staff' and TransactionDate ge datetime'#{4.weeks.ago.utc.iso8601}')",
        "(TransactionStatus eq 'Request Finished' and SystemID eq 'Reshare:upennbd' and TransactionDate ge datetime'#{10.days.ago.utc.iso8601}')",
        "(TransactionStatus ne 'Checked Out to Customer' and TransactionStatus ne 'Cancelled by ILL Staff' and TransactionStatus ne 'Request Finished')"
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
