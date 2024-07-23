# frozen_string_literal: true

module Library
  # Component rendering the location information for a library.
  class InfoComponent < ViewComponent::Base
    attr_reader :info, :code

    delegate(*%i[address1 address2 city state_code zip hours hours_url maps_url phone email library_url], to: :info)

    # @param library_code [String]
    def initialize(library_code:)
      @code = library_code
      @info = Library::Info::Request.find(library_code: code)
    end

    # @return [Boolean]
    def render?
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
      t('library.info.todays_hours', hours: hours) if hours.present?
    end

    # @return [String, nil]
    def hours_link
      link_to(t('library.info.view_more_hours'), hours_url) if hours_url.present?
    end

    # @return [String]
    def city_state_zip
      city_state = [city, state_code].compact.join(', ')

      [city_state, zip].compact.join(' ')
    end
  end
end
