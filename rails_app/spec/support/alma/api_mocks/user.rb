# frozen_string_literal: true

module Alma
  module ApiMocks
    module User
      # @param id [String]
      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_alma_user_find_success(id:, response_body:)
        stub_request(:get, "#{Alma::User.users_base_path}/#{id}?expand=fees,requests,loans")
          .to_return_json(status: 200, body: response_body, headers: {})
      end

      # @param user_id [String]
      # @param loan_id [String]
      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_alma_user_renew_loan_success(user_id:, loan_id:, response_body:)
        stub_request(:post, "#{Alma::User.users_base_path}/#{user_id}/loans/#{loan_id}?op=renew")
          .to_return_json(status: 200, body: response_body, headers: {})
      end

      # @param user_id [String]
      # @param loan_id [String]
      # @return [WebMock::RequestStub]
      def stub_alma_user_renew_loan_failure(user_id:, loan_id:)
        stub_request(:post, "#{Alma::User.users_base_path}/#{user_id}/loans/#{loan_id}?op=renew")
          .to_return_json(status: 400, body: loan_renewal_error(loan_id: loan_id), headers: {})
      end

      private

      # @return [Hash]
      def loan_renewal_error(loan_id)
        { 'errorsExist' => true, 'errorList' =>
          { 'error' => [{ 'errorCode' => '401823', 'errorMessage' => "Loan ID #{loan_id} does not exist.",
                          'trackingId' => 'E01-1305130124-RSBV7-AWAE129952489' }] } }
      end
    end
  end
end
