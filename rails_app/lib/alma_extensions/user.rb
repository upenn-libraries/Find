# frozen_string_literal: true

# rubocop:disable Style/HashSyntax, Style/GuardClause
module AlmaExtensions
  # Additional methods for Alma::User class that add the ability to:
  #   - fetch a single loan
  #   - fetch a single request
  #   - renew a loan
  #   - cancel a request
  module User
    # Fetch single loan
    #
    # @param [Hash] args
    # @option args [String] :user_id The unique id of the user
    # @option args [String] :loan_id The unique id of the loan
    def find_loan(args = {})
      loan_id = args.delete(:loan_id) { raise ArgumentError }
      user_id = args.delete(:user_id) { raise ArgumentError }
      response = HTTParty.get("#{users_base_path}/#{user_id}/loans/#{loan_id}", query: args, headers:, timeout:)

      if response.code == 200
        Alma::Loan.new(response)
      else
        raise StandardError, JSON.parse(response.body)
      end
    end

    # Fetch single request.
    #
    # @param [Hash] args
    # @option args [String] :user_id The unique id of the user
    # @option args [String] :request_id The unique id of the request
    def find_request(args = {})
      request_id = args.delete(:request_id) { raise ArgumentError }
      user_id = args.delete(:user_id) { raise ArgumentError }
      response = HTTParty.get("#{users_base_path}/#{user_id}/requests/#{request_id}", query: args, headers:)

      if response.code == 200
        Alma::UserRequest.new(response)
      else
        raise StandardError, JSON.parse(response.body)
      end
    end

    # Renew loan without requiring for the user to be fetched.
    #
    # @param [Hash] args
    # @option args [String] :user_id The unique id of the user
    # @option args [String] :loan_id The unique id of the loan
    def renew_loan(args = {})
      send_loan_renewal_request(args)
    end

    # Method to cancel user's request.
    #
    # @param [Hash] args
    # @option args [String] :user_id The unique id of the user
    # @option args [String] :request_id The unique id of the request
    def cancel_request(args = {})
      request_id = args.delete(:request_id) { raise ArgumentError }
      user_id = args.delete(:user_id) { raise ArgumentError }
      params = { reason: 'CancelledAtPatronRequest' }
      response = HTTParty.delete("#{users_base_path}/#{user_id}/requests/#{request_id}", query: params, headers:)

      # Raise an error if the response is not 204
      raise StandardError, JSON.parse(response.body) if response.code != 204
    end
  end
end
# rubocop:enable Style/HashSyntax, Style/GuardClause

Alma::User.extend(AlmaExtensions::User)
