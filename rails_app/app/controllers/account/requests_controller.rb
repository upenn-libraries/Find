# frozen_string_literal: true

module Account
  # Controller for submitting new Alma/ILL requests and displaying the "shelf" (containing Alma requests &
  # Illiad transactions & Alma loans).
  class RequestsController < AccountController
    before_action :set_mms_id, :set_holding_id, :set_items, only: :fulfillment_form

    rescue_from Shelf::Service::AlmaRequestError, Shelf::Service::IlliadRequestError do |e|
      Honeybadger.notify(e)
      Rails.logger.error(e.message)
      redirect_back_or_to requests_path, alert: 'There was an unexpected issue with your request.'
    end

    # Form for initializing an ILL form.
    # GET /account/requests/ill/new
    def ill; end

    # Submission logic using form params and request broker service
    # POST /account/request/submit
    def create
      # have all the item details needed (mms_id, holding_id, pickup_location, comments)
      # build our request POST body - Alma .submit method takes one big hash and creates the params/body automatically
      # use our request broker service (coming soon) to send the request
      # handle response, showing confirmation and/or error - maybe even send an email
      flash[:notice] = 'Your request has not been submitted. Requesting submission is not yet functional in Find.'
      redirect_to solr_document_path(id: params[:mms_id])
    end

    # List all shelf entries. Supports sort & filter params.
    # GET /account/requests and GET /account/shelf
    def index
      @listing = shelf_service.find_all
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

      redirect_to request_path(:ils, :hold, params[:id]), notice: t('account.shelf.cancel.success')
    end

    # Moves completed scan requests to "Request Finished" status - doesn't really delete.
    # DELETE /account/requests/ill/transaction/:id
    def delete_transaction
      shelf_service.delete_scan_transaction(params[:id])

      redirect_to requests_path, notice: t('account.shelf.delete.success')
    end

    # Return fulfillment options based on mms id/holding id/item id. Options are dependent
    # on properties of an item and user group. Returns a rendered OptionsComponent which uses
    # those options to determine what actions are available to the user.
    # GET /account/requests/options
    def options
      item = if params[:item_pid] == 'no-item'
               Inventory::Service::Physical.items(mms_id: params[:mms_id], holding_id: params[:holding_id]).first
             else
               Inventory::Service::Physical.item(mms_id: params[:mms_id],
                                                 holding_id: params[:holding_id],
                                                 item_pid: params[:item_pid])
             end
      options = item.fulfillment_options(ils_group: current_user.ils_group)
      render(Account::Requests::OptionsComponent.new(user: current_user, options: options), layout: false)
    end

    # Returns form with item select dropdown and sets up turbo frame for displaying options.
    # GET /account/requests/form?mms_id=XXXX&holding_id=XXXX
    def fulfillment_form
      render(Account::Requests::FormComponent.new(mms_id: @mms_id,
                                                  holding_id: @holding_id,
                                                  items: @items), layout: false)
    end

    private

    def shelf_service
      @shelf_service ||= Shelf::Service.new(current_user.uid)
    end

    # @return [String]
    def set_mms_id
      @mms_id = params[:mms_id]
    end

    # @return [String]
    def set_holding_id
      @holding_id = params[:holding_id]
    end

    # @return [Alma::BibItemSet]
    def set_items
      @items = Inventory::Service::Physical.items(mms_id: params[:mms_id],
                                                  holding_id: params[:holding_id])
    end
  end
end
