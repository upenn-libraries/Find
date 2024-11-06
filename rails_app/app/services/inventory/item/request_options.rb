# frozen_string_literal: true

module Inventory
  class Item
    # todo
    class RequestOptions
      attr_reader :user, :item

      # @param user [User, nil] the user object
      # @param item [Inventory::Item]
      def initialize(user:, item:)
        @user = user
        @item = item
      end

      # Return an array of fulfillment options for a given item and user. Certain requesting options (ie Aeon) are
      # available to non-logged in users.
      #
      # @return [Array<Symbol>]
      def all
        option = item.restricted_circ_type
        return Array.wrap(option) if option.present?

        return [] if user.nil? # If user is not logged in, no more requesting options can be exposed.

        return courtesy_borrower_options if user.courtesy_borrower?

        penn_borrower_options(user)
      end

      private

      # Fulfillment options available for Penn users.
      # @param user [User]
      # @return [Array<Symbol>]
      def penn_borrower_options(user)
        options = [Fulfillment::Request::Options::MAIL]
        options << Fulfillment::Request::Options::PICKUP if item.checkoutable?
        options << Fulfillment::Request::Options::OFFICE if user.faculty_express?
        options << Fulfillment::Request::Options::ELECTRONIC if item.scannable?
        options
      end

      # Fulfillment options available for courtesy borrowers. Courtesy borrowers can't make inter-library loan requests.
      # @return [Array<Symbol>]
      def courtesy_borrower_options
        item.checkoutable? ? [Fulfillment::Request::Options::PICKUP] : []
      end
    end
  end
end
