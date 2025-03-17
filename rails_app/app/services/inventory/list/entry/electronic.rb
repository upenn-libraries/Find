# frozen_string_literal: true

module Inventory
  class List
    module Entry
      # Electronic holding class
      class Electronic < Base
        # Base host, path, and params to electronic resource (portfolio) links via Alma "uresolver"
        # See: https://developers.exlibrisgroup.com/alma/integrations/discovery/fulfillment_services/
        HOST = Inventory::Constants::ERESOURCE_LINK_HOST
        PATH = Inventory::Constants::ERESOURCE_LINK_PATH
        PARAMS = {
          Force_direct: true, # link directly to the resource, not the Alma link resolver page
          test_access: true, # according to ExL, this must be used when a pid is specified and force_direct is true
          portfolio_pid: nil, # this will be set when generated
          rfr_id: Inventory::Constants::ERESOURCE_LINK_RFR_ID,
          'u.ignore_date_coverage': true # get all services from specified portfolio regardless of date coverage
        }.freeze

        # @return [String, nil]
        def id
          data[:portfolio_pid]
        end

        # @return [String]
        def description
          data[:collection].presence || I18n.t('inventory.fallback_electronic_access_button_label')
        end

        # @return [String, nil]
        def status
          data[:activation_status]
        end

        # User-friendly display value for inventory entry status
        # Electronic resources _should_ *ALWAYS* be "Available" - otherwise we shouldn't show them. If this proves to be
        # true we can simplify this.
        # @return [String, nil] status
        def human_readable_status
          case status
          when Constants::ELEC_AVAILABLE then I18n.t('alma.availability.electronic.available.label')
          when Constants::CHECK_HOLDINGS then I18n.t('alma.availability.electronic.check_holdings.label')
          when Constants::ELEC_UNAVAILABLE then I18n.t('alma.availability.electronic.unavailable.label')
          else
            status&.capitalize
          end
        end

        # No location available for electronic entries.
        def human_readable_location
          nil
        end

        # No policy available for electronic entries.
        #
        # @return [nil]
        def policy
          nil
        end

        # Format is only exposed via the Inventory::ElectronicDetail object to prevent additional API calls.
        def format
          nil
        end

        # @return [String, nil]
        def coverage_statement
          sanitize data[:coverage_statement], tags: ALLOWED_TAGS
        end

        # @return [String, nil]
        def public_note
          sanitize data[:public_note], tags: ALLOWED_TAGS
        end

        # @return [String, nil]
        def href
          return nil if id.blank?

          params = { **PARAMS, portfolio_pid: id }
          query = URI.encode_www_form(params)

          URI::HTTPS.build(host: HOST, path: PATH, query: query).to_s
        end

        # @return [String, nil]
        def collection_id
          data[:collection_id]
        end

        # @return [Boolean]
        def electronic?
          true
        end
      end
    end
  end
end
