# frozen_string_literal: true

module Alma
  module SRUMocks
    module Bib
      # @param id [String]
      # @param response_body [Hash]
      # @return [WebMock::RequestStub]
      def stub_sru_response(id:, response_body:)
        stub_request(:get, "#{Settings.alma.sru_endpoint}?maximumRecords=1&operation=searchRetrieve&query=alma.mms_id=#{id}&recordSchema=marcxml&version=1.2")
          .to_return_json(status: 200, body: response_body, headers: {})
      end
    end
  end
end
