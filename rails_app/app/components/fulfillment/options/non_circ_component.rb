# frozen_string_literal: true

module Fulfillment
  module Options
    # Component to render information about how to access a non-circulating item
    class NonCircComponent < ViewComponent::Base
      attr_accessor :message, :action, :type, :library

      def initialize(type:, action_link: nil, library: nil)
        @type = type
        @library = library
        @message = message_for(type: type)
        @action = action_link
      end

      # HTML id attribute for component
      # @return [String (frozen)]
      def id
        "#{type}-option"
      end

      private

      # @param [Symbol, nil] type
      # @return [String]
      def message_for(type:)
        t('requests.form.options.none.info') unless type

        case type
        when :hsp then t('requests.form.options.hsp.info_html', url: t('urls.requesting_info.hsp'))
        when :archives
          t('requests.form.options.archives.info_html', visit_url: t('urls.requesting_info.archives_visit'),
                                                        contact_url: t('urls.requesting_info.archives_contact'))
        when :reserves, :reference, :in_house
          t(:info, scope: %i[requests form options].push(type), library: library)
        else
          t(:info, scope: %i[requests form options].push(type))
        end
      end
    end
  end
end
