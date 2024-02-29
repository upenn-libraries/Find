# frozen_string_literal: true

module Inventory
  class Entry
    # Electronic holding class
    class Electronic < Inventory::Entry
      # Base host, path, and params to electronic resource (portfolio)
      HOST = 'upenn.alma.exlibrisgroup.com'
      PATH = '/view/uresolver/01UPENN_INST/openurl'
      PARAMS = { Force_direct: true,
                 portfolio_pid: nil,
                 rfr_id: 'info:sid/primo.exlibrisgroup.com',
                 'u.ignore_date_coverage': true }.freeze

      # @return [String, nil]
      def status
        data[:activation_status]
      end

      # @return [String, nil]
      def policy; end

      # @return [String, nil]
      def description
        data[:collection]
      end

      # @return [String, nil]
      def format
        return if portfolio.blank?

        portfolio.dig('material_type', 'desc')
      end

      # @return [String, nil]
      def id
        data[:portfolio_pid]
      end

      # @return [String, nil]
      def collection_id
        data[:collection_id]
      end

      # @note for a collection record (e.g. 9977925541303681) Electronic Collection API returns
      #       "url_override" field that has a neat hdl.library.upenn.edu link to the electronic collection
      # @return [String, nil]
      def href
        return nil if id.blank?

        params = { **PARAMS, portfolio_pid: id }
        query = URI.encode_www_form(params)

        # TODO: check if collection has url_override and use it (from @collection)

        URI::HTTPS.build(host: HOST, path: PATH, query: query).to_s
      end

      private

      def portfolio
        @portfolio ||= Alma::Electronic.get(collection_id: collection_id, service_id: nil,
                                            portfolio_id: id)&.data || {}
      end

      def collection
        @collection ||= Alma::Electronic.get(collection_id: collection_id)&.data || {}
      end
    end
  end
end
