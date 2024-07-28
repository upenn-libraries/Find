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
    def address_display
      address_content.map do |line|
        content_tag :p, line
      end
    end

    private

    # @return [String, nil]
    def hours_text
      t('library.info.todays_hours', hours: hours) if hours.present?
    end

    # @return [String, nil]
    def hours_link
      return if hours_url.blank?

      link_text = hours_text.present? ? t('library.info.view_more_hours') : t('library.info.view_hours')

      link_to link_text, hours_url
    end

    # @return [String]
    def city_state_zip
      # Don't render the city, state, zip line if one is missing
      return unless [city, state_code, zip].compact.length == 3

      "#{city}, #{state_code} #{zip}"
    end

    def address_content
      return if address1.blank?

      [address1, address2, city_state_zip].compact
    end
  end
end
