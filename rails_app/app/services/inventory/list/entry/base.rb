# frozen_string_literal: true

module Inventory
  class List
    module Entry
      # Abstract class that all Inventory entry classes inherit from. Establishes API that subclasses should adhere to.
      class Base
        include ActionView::Helpers::SanitizeHelper

        ALLOWED_TAGS = %w[strong b].freeze

        attr_reader :data, :mms_id

        # @param mms_id [String]
        # @param data [Hash] hash containing inventory data retrieved from Alma real time availability API
        # See Alma::AvailabilityResponse for mapping of values into the data hash
        def initialize(mms_id:, **data)
          @mms_id = mms_id
          @data = data
        end

        def id
          raise NotImplementedError
        end

        def description
          raise NotImplementedError
        end

        def status
          raise NotImplementedError
        end

        def human_readable_status
          raise NotImplementedError
        end

        def human_readable_location
          raise NotImplementedError
        end

        def policy
          raise NotImplementedError
        end

        def format
          raise NotImplementedError
        end

        def coverage_statement
          raise NotImplementedError
        end

        def public_note
          raise NotImplementedError
        end

        def href
          raise NotImplementedError
        end

        # @return [Boolean]
        def electronic?
          false
        end

        # @return [Boolean]
        def physical?
          false
        end

        # @return [Boolean]
        def resource_link?
          false
        end

        # @return [Boolean]
        def ecollection?
          false
        end

        # Determine if an Entry is missing data required for proper, meaningful display. Implementations that would
        # restrict display should be implemented in subclasses.
        # @return [Boolean]
        def displayable?
          true
        end
      end
    end
  end
end
