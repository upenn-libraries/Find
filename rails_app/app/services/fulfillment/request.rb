# frozen_string_literal: true

module Fulfillment
  # Submits Requests to Endpoint
  class Request
    class LogicFailure < StandardError; end

    attr_reader :patron, :requester, :params, :delivery, :pickup_location, :endpoint

    # Create a new Request to Broker
    #
    # This object would receive a wide variety of parameters and properly create a request object
    # capable of knowing how to submit itself and how to properly format the submission body.
    # The locations where these Requests will be created:
    # 1. ILL Request form: form submission will contain item parameters in the BOOK request case,
    #    and scan details in the SCAN request case. A BOOK request will include some fulfillment options.
    #    Library staff will be able to proxy requests for other users. These submissions will go to the ILL backend.
    # 2. Item Request form: form submission will include item identifiers and fulfillment options. No scan details.
    #    Aeon requests will come from here.
    #
    # @param requester [::User, Fulfillment::User] user making request
    # @param params [Hash] additional parameters to create request
    # @option params [String] delivery
    # @option params [String, nil] pickup_location
    # @option params [String, nil] proxy_for
    # @options params [Symbol, nil] endpoint
    def initialize(requester:, endpoint: nil, **params)
      @requester = requester
      @delivery = params.delete(:delivery)&.to_sym
      @pickup_location = params.delete(:pickup_location).presence
      @patron = proxy_user(params.delete(:proxy_for)) || requester

      # Set endpoint upon initialization so errors can be caught prior to submission.
      @endpoint = endpoint_class(endpoint) || determine_endpoint

      # Once the endpoint is set, build the params.
      build_params(params)
    end

    def validate
      @endpoint.validate(request: self)
    end

    def submit
      @endpoint.submit(request: self)
    end

    def proxied?
      patron&.uid != requester&.uid
    end

    # @return [Boolean]
    def scan?
      delivery == Options::Deliverable::ELECTRONIC
    end

    # @return [Boolean]
    def mail?
      delivery == Options::Deliverable::MAIL
    end

    # @return [Boolean]
    def office?
      delivery == Options::Deliverable::OFFICE
    end

    # def aeon?
    #   delivery == Options::AEON
    # end

    # @return [Boolean]
    def pickup?
      delivery == Options::Deliverable::PICKUP
    end

    # @return [Boolean]
    def ill_pickup?
      delivery == Options::Deliverable::ILL_PICKUP
    end

    private

    # Returns User-like object for uid given. Does not validate uid.
    #
    # @return [nil] if no uid is present
    # @return [Fulfillment::User] if uid is present
    def proxy_user(uid)
      return if uid.blank?

      Fulfillment::User.new(uid)
    end

    # @param params [Hash]
    def build_params(params)
      @params = "#{endpoint}::Params".safe_constantize.new(params)
    end

    # Create endpoint class based on type.
    # @param type [Symbol] type of request, :illiad or :alma
    # @return [Class, nil]
    def endpoint_class(type)
      return if type.blank?

      "Fulfillment::Endpoint::#{type.to_s.camelcase}".safe_constantize
    end

    # Determine what endpoint should be used based on the delivery method.
    def determine_endpoint
      if scan? || mail? || office? || ill_pickup?
        Fulfillment::Endpoint::Illiad
        # elsif aeon?
        #   Fulfillment::Endpoint::Aeon
      elsif pickup?
        Fulfillment::Endpoint::Alma
      else
        raise LogicFailure, "Could not determine a submission endpoint for request: #{inspect}"
      end
    end
  end
end
