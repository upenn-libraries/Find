# frozen_string_literal: true

module Fulfillment
  # Submits Requests to Endpoint
  class Request
    class LogicFailure < StandardError; end

    ITEM_PARAMETERS = %w[mms_id holding_id item_id title author year edition publisher place isbn comments].freeze
    FULFILLMENT_PARAMETERS = %w[pickup_location delivery].freeze # TODO: proxy request parameters would go here, FacEx?
    SCAN_DETAIL_PARAMETERS = %w[journal article rftdate volume issue pages comments].freeze

    module Options
      AEON = :aeon
      ELECTRONIC_DELIVERY = :electronic
      HOME_DELIVERY = :home_delivery
      OFFICE_DELIVERY = :office_delivery
      PICKUP = :pickup
    end

    attr_reader :user, :raw_params, :item_parameters, :fulfillment_options, :scan_details, :endpoint

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
    def initialize(user:, params:)
      @user = user
      @raw_params = params
      @item_parameters = params.permit(ITEM_PARAMETERS)
      @fulfillment_options = params.permit(FULFILLMENT_PARAMETERS)
      @scan_details = params.permit(SCAN_DETAIL_PARAMETERS)
      set_endpoint # set endpoint upon initialization so errors can be caught prior to submission
    end

    # Convenience method for submitting directly
    # @param [User] user
    # @param [ActionController::Params]
    def self.submit(user:, params:)
      request = new(user: user, params: params)
      Service.new(request: request).submit
    end

    def set_endpoint
      @endpoint = if scan? || books_by_mail? || delivery? || ill_pickup?
                    Fulfillment::Endpoint::Illiad
                  elsif aeon?
                    Fulfillment::Endpoint::Aeon
                  elsif pickup?
                    Fulfillment::Endpoint::Alma
                  else
                    raise LogicFailure, "Could not determine a submission endpoint for request: #{inspect}"
                  end
    end

    def scan?
      fulfillment_options[:delivery] == Options::ELECTRONIC_DELIVERY
    end

    def books_by_mail?
      fulfillment_options[:delivery] == Options::HOME_DELIVERY
    end

    def delivery?
      fulfillment_options[:delivery] == Options::OFFICE_DELIVERY
    end

    def aeon?
      fulfillment_options[:delivery] == Options::AEON
    end

    def pickup?
      fulfillment_options[:delivery]&.to_sym == Options::PICKUP &&
        (item_parameters[:holding_id].present? || item_parameters[:item_id].present?)
    end

    def ill_pickup?
      fulfillment_options[:delivery] == Options::PICKUP &&
        (item_parameters[:holding_id].blank? && item_parameters[:item_id].blank?)
    end
  end
end
