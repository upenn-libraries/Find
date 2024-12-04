# frozen_string_literal: true

module Fulfillment
  # Create and submits fulfillment requests to an Endpoint. Sends notifications after successful submission.
  # Usage: Fulfillment::Service.submit(params)
  #        Will return a successful or failed Fulfillment::Outcome
  class Service
    class << self
      # Determine the eligible fulfillment options for an item & user combo
      # @param item [Inventory::Item] item for use in determining fulfillment options
      # @param user [User] user for use in determining fulfillment options
      # @return [OptionsSet]
      def options(item:, user:)
        OptionsSet.new(item: item, user: user)
      end

      # Creates a request with the parameters provided.
      #
      # @param (see Fulfillment::Request#initialize)
      # @return [Fulfillment::Request]
      def request(**params)
        Request.new(**params)
      end

      # Create and submit request to the correct Endpoint class. Ensure any exception is rescued
      # and return an Outcome in all cases.
      #
      # @param (see Fulfillment::Request#initialize)
      # @return [Fulfillment::Outcome]
      def submit(**params)
        request = request(**params)
        errors = request.validate
        return failed_outcome(request, errors) if errors.any?

        outcome = request.submit
        notify outcome: outcome
        outcome
      rescue StandardError => e
        Rails.logger.error e.message
        Honeybadger.notify(e)
        failed_outcome(request, [I18n.t('fulfillment.public_error_message')])
      end

      # @param [Outcome] outcome
      def notify(outcome:)
        RequestMailer.confirmation_email(outcome: outcome).deliver_now
      end

      private

      # @return [Fulfillment::Outcome]
      def failed_outcome(request, errors)
        Outcome.new(request: request, errors: errors)
      end
    end
  end
end
