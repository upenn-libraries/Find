# frozen_string_literal: true

# Item requesting controller
class RequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mms_id
  before_action :set_holding_id, only: :new
  before_action :set_holdings, only: :new
  before_action :set_items, only: %w[new item_labels]
  before_action :set_alma_user, only: :new

  def new; end

  # Submit body from Franklin
  # body = { 'request_type' => 'HOLD', 'pickup_location_type' => 'LIBRARY',
  #                'pickup_location_library' => request.pickup_location,
  #                'comment' => request.comments }

  def submit
    # have all the item details needed (mms_id, holding_id, pickup_location, comments)
    # build our request POST body - Alma .submit method takes one big hash and creates the params/body automatically
    # send via Alma::BibRequest.submit OR Alma::ItemRequest.submit
    # handle response, showing confirmation and/or error - maybe even send an email
    flash[:notice] = 'Requesting submission needs to be implemented.'
    redirect_to solr_document_path(id: params[:mms_id])
  end

  # return fulfillment options based on mms id/holding id/item id
  def options
    # @item = Alma::BibItem.find()
    @user = current_user
    # options = Items::Service.options_for(mms_id:, holding_id:, item_id:, user_id:)
    # ex:, options = [:delivery, :pickup]
    # TODO: return turbo frame content with option form radio button elements
    # render Account::Requests::OptionsComponent.new(options: options)
  end

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
    @item = Items::Service.item_for(mms_id: params[:mms_id], holding_id: params[:holding_id],
                                    item_pid: @items.first.item_data['pid'])
  end

  def set_alma_user
    # Implement some logic here to determine default library selection based on user group
    # User group is stored in session[:user_group] if the user exists in Alma
    # @user_group = session[:user_group]
    @alma_user = Alma::User.find(current_user.uid)
  end
end
