# frozen_string_literal: true

module Find
  module ShowDocument
    module InventoryContent
      # Component rendering the location information for a library.
      class LibInfoComponent < ViewComponent::Base
        attr_reader :info

        delegate(*%i[address1 address2 city state_code zip hours hours_url maps_url phone email library_url], to: :info)

        # @param entry [Inventory::Entry]
        # @info [LibInfo::Request]
        def initialize(entry:)
          @entry = entry
          @info = entry.location_info
        end

        def info?
          info.present?
        end

        # @return [Array<String>]
        def hours_content
          [hours_text, hours_link].compact
        end

        # @return [Array<String>]
        def address_content
          address_raw = [address1, address2, city_state_zip].compact

          address_raw.map do |line|
            content_tag(:p, line)
          end
        end

        private

        # @return [String, nil]
        def hours_text
          t('library_info.todays_hours', hours: hours) if hours.present?
        end

        # @return [String, nil]
        def hours_link
          link_to(t('library_info.view_more_hours'), hours_url) if hours_url.present?
        end

        # @return [String]
        def city_state_zip
          city_state = [city, state_code].compact.join(', ')

          [city_state, zip].compact.join(' ')
        end
      end
    end
  end
end
