# frozen_string_literal: true

module Account
  # Controller for submitting new Alma/ILL requests and displaying the "shelf" (containing Alma requests &
  # Illiad transactions & Alma loans).
  class RequestsController < AccountController
    before_action :set_mms_id
    before_action :set_holding_id, only: %w[new form]
    before_action :set_items, only: %w[new options form]

    # Returns form for initializing a new request. TODO: May return a turbo frame response.
    # GET /account/requests/new
    def new; end

    # Form for initializing an ILL form.
    # GET /account/request/ill/new
    def ill
      @item = Items::Service.item_for(mms_id: params[:mms_id], holding_id: params[:holding_id],
                                      item_pid: params[:item_pid])
    end

    # Submission logic using form params and request broker service
    # POST /account/request/submit
    def create
      # have all the item details needed (mms_id, holding_id, pickup_location, comments)
      # build our request POST body - Alma .submit method takes one big hash and creates the params/body automatically
      # use our request broker service (coming soon) to send the request
      # handle response, showing confirmation and/or error - maybe even send an email
      flash[:notice] = 'Requesting submission needs to be implemented.'
      redirect_to solr_document_path(id: params[:mms_id])
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

    # return fulfillment options based on mms id/holding id/item id
    # GET /account/requests/options
    def options
      # options = Items::Service.options_for(mms_id:, holding_id:, item_id:, user_id:)
      item = Items::Service.item_for(mms_id: params[:mms_id],
                                     holding_id: params[:holding_id],
                                     item_pid: params[:item_pid])
      options = Items::Service.options_for(item: item, ils_group: current_user.ils_group)
      # options would be passed into the component to determine which options are available
      render(Account::Requests::OptionsComponent.new(item: item, user: current_user, options: options), layout: false)
    end

    # Returns form with item select dropdown and sets up turbo frame for displaying options.
    # GET /account/requests/form?mms_id=XXXX&holding_id=XXXX
    # TODO: better name?
    def form
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
      @items = Items::Service.items_for(mms_id: params[:mms_id],
                                        holding_id: params[:holding_id])
    end
  end
end
