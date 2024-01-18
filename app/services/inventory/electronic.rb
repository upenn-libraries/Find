# frozen_string_literal: true

module Inventory
  # Electronic holding class
  class Electronic < Base
    # Base host, path, and params to electronic resource (portfolio)
    HOST = 'upenn.alma.exlibrisgroup.com'
    PATH = '/view/uresolver/01UPENN_INST/openurl'
    PARAMS = { Force_direct: true,
               portfolio_pid: nil,
               rfr_id: 'info:sid/primo.exlibrisgroup.com',
               'u.ignore_date_coverage': true }.freeze

    # @return [String, nil]
    def status
      raw_api_data['activation_status']
    end

    # @return [String, nil]
    def policy; end

    # @return [String, nil]
    def description
      raw_api_data['collection']
    end

    # @return [String, nil]
    def format; end

    # @return [String, nil]
    def id
      raw_api_data['portfolio_pid']
    end

    # @return [String, nil]
    def href
      return nil if id.blank?

      params = { **PARAMS, portfolio_pid: id }
      query = URI.encode_www_form(params)

      URI::HTTPS.build(host: HOST, path: PATH, query: query).to_s
    end
  end
end
