# frozen_string_literal: true

module Inventory
  class List
    module Entry
      # Physical holding class
      class Physical < Base
        # @return [String, nil]
        def status
          return Constants::UNAVAILABLE if first_item_requested?

          data[:availability]
        end

        # User-friendly display value for inventory entry status
        # @return [String, nil]
        def human_readable_status
          refined_status.label
        end

        # User-friendly display value for inventory entry status description - a more detailed description of
        # what the status indicates
        # @return [String, nil]
        def human_readable_status_description
          refined_status.description
        end

        # @return [String, nil]
        def policy
          return if first_item.nil?

          first_item.item_data.dig('policy', 'desc')
        end

        # @return [String, nil]
        def description
          data[:call_number]
        end

        # @return [String, nil]
        def format
          return if first_item.nil?

          first_item.item_data.dig('physical_material_type', 'desc')
        end

        # @return [String, nil]
        def coverage_statement
          data[:holding_info]
        end

        # @return [nil]
        def public_note
          nil
        end

        # @return [String, nil]
        def id
          data[:holding_id]
        end

        # @return [String, nil]
        def href
          # Items in a temporary location don't return a holding ID in the availability response.
          return Rails.application.routes.url_helpers.solr_document_path(mms_id) if id.blank?

          Rails.application.routes.url_helpers.solr_document_path(mms_id, hld_id: id)
        end

        # @return [String, nil]
        def human_readable_location
          # Passing call number and type to get any location overrides that might be present.
          location.name(call_number: data[:call_number], call_number_type: data[:call_number_type])
        end

        # @return [Inventory::Location]
        def location
          @location ||= Inventory::Location.new(
            location_code: data[:location_code], location_name: data[:location],
            library_code: data[:library_code], library_name: data[:library]
          )
        end

        # Returns host record mms id, if physical holding is a boundwith.
        def host_record_id
          data[:host_record_id]
        end

        # Number of items for this physical holding.
        #
        # @return [String, nil]
        def count
          data[:total_items]
        end

        def physical?
          true
        end

        private

        # Check if the first item is requested - this is implemented for a specific condition:
        # The AVA tag changes to Unavailable only after the item has been pulled from the
        # shelf and scanned, which could be several hours.
        #
        # @return [Boolean] if the first item has been requested
        def first_item_requested?
          return false unless count.to_i == 1 && first_item.present?

          first_item.item_data.fetch('requested', false)
        end

        # User-friendly availability status.
        #
        # @return [Inventory::List::Entry::Physical::Status]
        def refined_status
          @refined_status ||= Status.new(status: status, location: location)
        end

        def first_item
          @first_item ||= find_first_item
        end

        def find_first_item(**options)
          default_options = { holding_id: id, expand: 'due_date,due_date_policy', limit: 1 }
          resp = Alma::BibItem.find(mms_id, default_options.merge(options))
          resp.items.first
        end
      end
    end
  end
end
