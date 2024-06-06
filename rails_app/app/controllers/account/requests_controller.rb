# frozen_string_literal: true

module Account
  # Controller for submitting new Alma/ILL requests and displaying the "shelf" (containing Alma requests &
  # Illiad transactions & Alma loans).
  class RequestsController < AccountController
    before_action :set_mms_id, :set_holding_id, :set_items, only: :fulfillment_form

    # Form for initializing an ILL form.
    # GET /account/requests/ill/new
    def ill
      @ill_params = Fulfillment::Endpoint::Illiad::Params.new(raw_params)
    end

    # Submission logic using form params and request broker service
    # POST /account/request/submit
    def create
      outcome = Fulfillment::Request.submit(user: current_user, params: raw_params)
      if outcome.success?
        flash[:notice] = 'Your request has been successfully submitted.'
        redirect_to shelf_path
      else
        flash[:alert] = "We could not submit your request due to the following: #{outcome.message}"
        redirect_back_or_to root_path
      end
    end

    # List all shelf entries. Supports sort & filter params.
    # GET /account/requests and GET /account/shelf
    def index; end

    # Show all details of a shelf entry. May not be needed based on index page design.
    # GET /account/requests/:system/:id
    def show; end

    # Renew an Alma loan.
    # POST /account/requests/ils/:id/renew
    def renew; end

    # Cancel an Alma HOLD request.
    # DELETE /account/requests/ils/:id
    def delete; end

    # Return fulfillment options based on mms id/holding id/item id. Options are dependent
    # on properties of an item and user group. Returns a rendered OptionsComponent which uses
    # those options to determine what actions are available to the user.
    # GET /account/requests/options
    def options
      item = if params[:item_id] == 'no-item'
               Inventory::Service::Physical.items(mms_id: params[:mms_id], holding_id: params[:holding_id]).first
             else
               Inventory::Service::Physical.item(mms_id: params[:mms_id],
                                                 holding_id: params[:holding_id],
                                                 item_id: params[:item_id])
             end
      options = item.fulfillment_options(ils_group: current_user.ils_group) # TODO: could do this in OptionsComponent
      render(Account::Requests::OptionsComponent.new(user: current_user, item: item, options: options), layout: false)
    end

    # Returns form with item select dropdown and sets up turbo frame for displaying options.
    # GET /account/requests/form?mms_id=XXXX&holding_id=XXXX
    def fulfillment_form
      render(Account::Requests::FormComponent.new(mms_id: @mms_id,
                                                  holding_id: @holding_id,
                                                  items: @items), layout: false)
    end

    private

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

    def raw_params
      params.except(:controller, :action).to_unsafe_h.with_indifferent_access
    end
  end
end
