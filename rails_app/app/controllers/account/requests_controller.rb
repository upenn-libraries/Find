# frozen_string_literal: true

module Account
  # Controller for submitting new Alma/ILL requests and displaying the "shelf" (containing Alma requests &
  # Illiad transactions & Alma loans).
  class RequestsController < AccountController
    before_action :block_courtesy_borrowers, only: :ill

    rescue_from Shelf::Service::AlmaRequestError, Shelf::Service::IlliadRequestError do |e|
      Honeybadger.notify(e)
      Rails.logger.error(e.message)
      redirect_back_or_to requests_path, alert: 'There was an unexpected issue with your request.'
    end

    # Form for initializing an ILL form.
    # GET /account/requests/ill/new
    def ill
      @request = Fulfillment::Service.request(requester: current_user, endpoint: :illiad, **raw_params)

      if @request.proxied? && !current_user.library_staff?
        flash.now[:alert] = t('fulfillment.validation.no_proxy_requests')
      elsif @request.proxied? && !@request.patron.alma_record?
        flash.now[:alert] = t('fulfillment.validation.proxy_invalid')
      elsif @request.patron.courtesy_borrower?
        flash.now[:alert] = t('fulfillment.validation.no_courtesy_borrowers')
      end
    end

    # Submission logic using form params and request broker service
    # POST /account/request/submit
    def create
      outcome = Fulfillment::Service.submit(requester: current_user, **raw_params)
      if outcome.success?
        flash[:notice] = 'Your request has been successfully submitted.'
        redirect_to shelf_path
      else
        flash[:alert] = "We could not submit your request due to the following: #{outcome.error_message}"
        redirect_back_or_to root_path
      end
    end

    # List all shelf entries. Supports sort & filter params.
    # GET /account/requests and GET /account/shelf
    def index
      @listing = shelf_service.find_all(**filtering_and_sorting_params)
    end

    # GET /account/requests/:system/:type/:id
    def show
      @entry = shelf_service.find(params[:system], params[:type], params[:id])
    end

    # Renew an Alma loan. Displaying the messages returned by the Alma gem.
    # POST /account/requests/ils/loan/:id/renew
    def renew
      response = shelf_service.renew_loan(params[:id])

      flash_type = response.renewed? ? :notice : :alert
      flash[flash_type] = response.message

      redirect_to request_path(:ils, :loan, params[:id])
    end

    # Renew all eligible Alma loans. Displaying the messages returned by the Alma gem.
    # POST /account/requests/ils/loan/renew_all
    def renew_all
      responses = shelf_service.renew_all_loans

      alert_text = t('account.shelf.renew_all.alerts',
                     alerts: responses.map { |r| t('account.shelf.renew_all.alert', alert: r.message) }.join)

      flash_type = responses.all?(&:renewed?) ? :notice : :alert
      flash[flash_type] = alert_text

      redirect_to requests_path
    end

    # Cancel an Alma HOLD request.
    # DELETE /account/requests/ils/hold/:id
    def delete_hold
      shelf_service.cancel_hold(params[:id])

      redirect_to requests_path, notice: t('account.shelf.cancel.success')
    end

    # Moves completed scan requests to "Request Finished" status - doesn't really delete.
    # DELETE /account/requests/ill/transaction/:id
    def delete_transaction
      shelf_service.delete_scan_transaction(params[:id])

      redirect_to requests_path, notice: t('account.shelf.delete.success')
    end

    private

    def shelf_service
      @shelf_service ||= Shelf::Service.new(current_user.uid)
    end

    def raw_params
      params.except(:controller, :action).to_unsafe_h.deep_symbolize_keys
    end

    def filtering_and_sorting_params
      sort_parts = params[:sort]&.rpartition('_')

      {
        filters: params[:filters]&.map(&:to_sym),
        sort: sort_parts&.first&.to_sym,
        order: sort_parts&.last&.to_sym
      }.compact_blank
    end

    def block_courtesy_borrowers
      return unless current_user.courtesy_borrower?

      redirect_to root_path, alert: t('fulfillment.validation.no_courtesy_borrowers')
    end
  end
end
