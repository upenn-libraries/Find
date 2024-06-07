# frozen_string_literal: true

module Fulfillment
  # Submits Requests to Endpoint
  class Request
    class LogicFailure < StandardError; end

    ITEM_PARAMETERS = %i[mms_id holding_id item_id title author year edition publisher place isbn comments pmid].freeze
    SCAN_DETAIL_PARAMETERS = %i[journal article rftdate volume issue pages comments].freeze

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
    # @param [ActionController::Params]
    def initialize(user:, delivery:, pickup_location: nil, **params)
      @user = user
      @delivery = delivery.to_sym
      @pickup_location = pickup_location

      determine_endpoint # set endpoint upon initialization so errors can be caught prior to submission
      build_params(params)
    end

    # Convenience method for submitting directly
    # @param params [Hash]
    def self.submit(**params)
      request = new(**params)
      Service.new(request: request).submit
    end

    def build_params(params)
      @params = "#{endpoint}::Params".constantize.new(params)
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

    def scan?
      delivery == Options::ELECTRONIC
    end

    def mail?
      delivery == Options::MAIL
    end

    def office?
      delivery == Options::OFFICE
    end

    # def aeon?
    #   delivery == Options::AEON
    # end

    def pickup?
      delivery == Options::PICKUP
    end

    def ill_pickup?
      delivery == Options::ILL_PICKUP
    end
  end
end
