# frozen_string_literal: true

module Fulfillment
  module Options
    # Component to render information about how to access a non-circulating item
    class OnSiteComponent < ViewComponent::Base
      attr_accessor :action, :type, :library

      def initialize(type:, action_link: nil, library: nil)
        @type = type
        @library = library
        @action = action_link
      end

      # HTML id attribute for component
      # @return [String (frozen)]
      def id
        "#{type}-option"
      end

      # Message to display in the alert
      # @return [String]
      def message
        message_for(type: type)
      end

      private

      # @param [Symbol, nil] type
      # @return [String]
      def message_for(type:)
        t('requests.form.options.unavailable.info') unless type

        non_circ_type_message type: type
      end

      # If we have a specific type of non-circ policy, show a more detailed message
      # @param [Symbol] type
      # @return [String]
      def non_circ_type_message(type:)
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
