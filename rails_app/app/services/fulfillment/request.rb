# frozen_string_literal: true

module Fulfillment
  # Submits Requests to Endpoint
  class Request
    class LogicFailure < StandardError; end

    # These symbols are the fulfillment options to be used throughout the app
    module Options
      # AEON = :aeon
      ELECTRONIC = :electronic
      MAIL = :mail
      OFFICE = :office
      PICKUP = :pickup
      ILL_PICKUP = :ill_pickup
    end

    attr_reader :user, :params, :delivery, :pickup_location, :endpoint

    # Create a new Request to Broker
    #
    # This object would receive a wide variety of parameters and properly create a request object
    # capable of knowing how to submit itself and how to properly format the submission body.
    # The locations where these Requests will be created:
    # 1. ILL Request form: form submission will contain item parameters in the BOOK request case,
    #    and scan details in the SCAN request case. A BOOK request will include some fulfillment options.
    #    We have to also consider the "Proxy" request functionality. These submissions will go to the ILL backend.
    # 2. Item Request form: form submission will include item identifiers and fulfillment options. No scan details.
    #    Aeon requests will come from here.
    # @param [User] user
    # @option delivery [String]
    # @option pickup_location [String, nil]
    def initialize(user:, **params)
      @user = user
      @delivery = params.delete(:delivery)&.to_sym
      @pickup_location = params.delete(:pickup_location).presence

      determine_endpoint # set endpoint upon initialization so errors can be caught prior to submission
      build_params(params)
    end

    # Convenience method for submitting directly
    # @param params [Hash]
    def self.submit(**params)
      request = new(**params)
      Service.new(request: request).submit
    end

    # @param params [Hash]
    def build_params(params)
      @params = "#{endpoint}::Params".safe_constantize.new(params)
    end

    def determine_endpoint
      @endpoint = if scan? || mail? || office? || ill_pickup?
                    Fulfillment::Endpoint::Illiad
                  # elsif aeon?
                  #   Fulfillment::Endpoint::Aeon
                  elsif pickup?
                    Fulfillment::Endpoint::Alma
                  else
                    raise LogicFailure, "Could not determine a submission endpoint for request: #{inspect}"
                  end
    end

    # @return [Boolean]
    def scan?
      delivery == Options::ELECTRONIC
    end

    # @return [Boolean]
    def mail?
      delivery == Options::MAIL
    end

    # @return [Boolean]
    def office?
      delivery == Options::OFFICE
    end

    # def aeon?
    #   delivery == Options::AEON
    # end

    # @return [Boolean]
    def pickup?
      delivery == Options::PICKUP
    end

    # @return [Boolean]
    def ill_pickup?
      delivery == Options::ILL_PICKUP
    end
  end
end
