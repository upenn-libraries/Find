# frozen_string_literal: true

module Inventory
  class List
    module Entry
      # Represents an inventory entry that comes from the MARC record
      class ResourceLink < Base
        ID_PREFIX = 'resource_link_'

        attr_reader :id, :href

        # @param link_url [String]
        # @param link_text [String]
        # @param id [String]
        def initialize(link_url:, link_text:, id:, **)
          @href = link_url
          @link_text = link_text.strip
          @id = "#{ID_PREFIX}#{id}"
        end

        # Description would ideally be the website_name, in cases were the website_name
        # is not available use the link_text.
        def description
          website_name || @link_text
        end

        # No location needed for resource link.
        def human_readable_location
          nil
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

        # Coverage statement should be the link_text provided. In cases where a hostname is not
        # extracted, the link_text is used at the description and shouldn't be displayed again.
        #
        # @return [String, nil]
        def coverage_statement
          website_name ? @link_text : nil
        end

        # @return [nil]
        def public_note
          nil
        end

        # @return [Boolean]
        def resource_link?
          true
        end

        private

        # Extract hostname from URL. Eventually we should pull this value from 856$a.
        def hostname
          @hostname ||= begin
            URI.parse(href).host
          rescue URI::InvalidURIError
            nil
          end
        end

        # Map hostname to a website name we can display to users.
        def website_name
          @website_name ||= Settings.websites[hostname]
        end
      end
    end
  end
end
