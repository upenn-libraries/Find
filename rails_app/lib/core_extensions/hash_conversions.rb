# frozen_string_literal: true

module CoreExtensions
  # Adds a method to convert a hash to an OpenURL query string
  module HashConversions
    def to_openurl
      filter_map { |key, value|
        next if value.blank?

        Array.wrap(value).filter_map do |v|
          "#{CGI.escape(key.to_s)}=#{CGI.escape(v.to_s)}"
        end
      }.flatten.join('&')
    end
  end
end

Hash.include CoreExtensions::HashConversions
