# frozen_string_literal: true

module Account
  # Item requesting controller
  class RequestsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_mms_id
    before_action :set_holding_id, only: :new
    before_action :set_holdings, only: :new
    before_action :set_items, only: %w[new item_labels options]
    before_action :set_alma_user, only: %w[new options]

    # Returns form for initializing a new request. TODO: May return a turbo frame response.
    # GET /account/requests/new
    def new; end

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
      @item = Items::Service.item_for(mms_id: params[:mms_id], holding_id: params[:holding_id],
                                      item_pid: params[:item_pid] || @items.first.item_data['pid'])
      # options would be passed into the component to determine which options are available
      render(Account::Requests::OptionsComponent.new(item: @item, alma_user: @alma_user), layout: false)
    end

    # Send json array of item labels to populate Item dropdown on holding change
    # GET /account/requests/item_labels
    def item_labels
      render json: @items.map(&:select_label)
    end

    private

    def set_mms_id
      @mms_id = params[:mms_id]
    end

    def set_holding_id
      @holding_id = params[:holding_id]
    end

    # @return [Alma::BibItemSet]
    def set_holdings
      @holdings = Alma::Bib.get_availability([params[:mms_id]])
                           .availability.dig(params[:mms_id], :holdings)
    end

    # @return [Alma::BibItemSet]
    def set_items
      @items = Items::Service.items_for(mms_id: params[:mms_id],
                                        holding_id: params[:holding_id])
    end

    def set_alma_user
      # Implement some logic here to determine default library selection based on user group
      # User group is stored in session[:user_group] if the user exists in Alma
      # @user_group = session[:user_group]
      @alma_user = Alma::User.find(current_user.uid)
    end
  end
end
