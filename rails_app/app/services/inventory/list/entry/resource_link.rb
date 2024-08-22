# frozen_string_literal: true

module Inventory
  class List
    module Entry
      # Represents an inventory entry that comes from the MARC record
      class ResourceLink < Base
        ID_PREFIX = 'resource_link_'

        attr_reader :id, :href, :description

        # @param href [String]
        # @param description [String]
        # @param id [String]
        def initialize(href:, description:, id:, **)
          @href = href
          @description = description.strip
          @id = "#{ID_PREFIX}#{id}"
        end

        # @return [String]
        def human_readable_location
          'Online'
        end

        # Policy not available for resource link.
        def policy
          nil
        end

        # @return [String]
        def status
          Inventory::Constants::AVAILABLE
        end

        # ResourceLink entries are always available
        # @return [String]
        def human_readable_status
          I18n.t('alma.availability.electronic.available.label')
        end

        # Format not available for resource link.
        def format
          nil
        end

        # Coverage statement not available for resource link.
        def coverage_statement
          nil
        end

        # @return [Boolean]
        def resource_link?
          true
        end
      end
    end
  end
end
