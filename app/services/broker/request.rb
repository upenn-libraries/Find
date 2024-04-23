# frozen_string_literal: true

module Broker
  # Submits Requests to Backend
  class Request
    class LogicFailure < StandardError; end

    module FulfillmentOptions
      AEON = :aeon
      ELECTRONIC = :electronic
      HOME_DELIVERY = :home_delivery
      OFFICE_DELIVERY = :office_delivery
      PICKUP = :pickup
    end

    attr_reader :user, :item_parameters, :fulfillment_options, :scan_details

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
    def initialize(user:, item_parameters: {}, fulfillment_options: {}, scan_details: {})
      @user = user
      @item_parameters = item_parameters
      @fulfillment_options = fulfillment_options
      @scan_details = scan_details
    end

    def self.submit(user:, item_parameters: {}, fulfillment_options: {}, scan_details: {})
      Service.submit(new(user: user, item_parameters: item_parameters, fulfillment_options: fulfillment_options,
                         scan_details: scan_details))
    end

    def destination
      if scan? || books_by_mail? || delivery? || ill_pickup?
        :illiad
      elsif aeon?
        :aeon
      elsif pickup?
        :alma
      else
        raise LogicFailure, "Could not determine a backend for request: #{inspect}"
      end
    end

    def scan?
      fulfillment_options[:method] == FulfillmentOptions::ELECTRONIC
    end

    def books_by_mail?
      fulfillment_options[:method] == FulfillmentOptions::HOME_DELIVERY
    end

    def delivery?
      fulfillment_options[:method] == FulfillmentOptions::OFFICE_DELIVERY
    end

    def aeon?
      fulfillment_options[:method] == FulfillmentOptions::AEON
    end

    def pickup?
      fulfillment_options[:method] == FulfillmentOptions::PICKUP &&
        (item_parameters[:holding_id].present? || item_parameters[:item_id].present?)
    end

    def ill_pickup?
      fulfillment_options[:method] == FulfillmentOptions::PICKUP &&
        (item_parameters[:holding_id].blank? && item_parameters[:item_id].blank?)
    end
  end
end
