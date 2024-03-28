# frozen_string_literal: true

# Item requesting controller
class ItemRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mms_id
  before_action :set_holding_id, only: %w[new]
  before_action :set_holding_labels, only: %w[new]
  before_action :set_item_labels, only: %w[new item_labels]
  before_action :set_default_library, only: %w[new]

  def new; end

  # Submit body from Franklin
  # body = { 'request_type' => 'HOLD', 'pickup_location_type' => 'LIBRARY',
  #                'pickup_location_library' => request.pickup_location,
  #                'comment' => request.comments }

  def submit
    # have all the item details needed (coming from form)
    # build our request POST body
    # send via Alma::BibRequest.submit
    # handle response, showing confirmation and/or error - maybe even send an email
    flash[:notice] = 'Requesting submission needs to be implemented.'
    redirect_to solr_document_path(id: params[:mms_id])
  end

  def item_labels
    render json: @item_labels
  end

  private

  def set_mms_id
    @mms_id = params[:mms_id]
  end

  def set_holding_id
    @holding_id = params[:holding_id]
  end

  def set_holding_labels
    holdings = Alma::Bib.get_availability([params[:mms_id]])
                        .availability.dig(params[:mms_id], :holdings)
    @holding_labels = holdings.filter_map { |holding| holding_label(holding) }
  end

  def set_item_labels
    items = Alma::BibItem.find(params[:mms_id], holding_id: params[:holding_id])
    @item_labels = items.filter_map { |item| item_label(item) }.sort
  end

  def set_default_library
    # Implement some logic here to detemine default library selection based on user group
    # User group is stored in session[:user_group] if the user exists in Alma
    @default_library = 'VanPeltLib'
  end

  def holding_label(holding)
    [[holding['library'], holding['call_number']].compact_blank.join(' - '), holding['holding_id']]
  end

  def item_label(item)
    [[item.description, item.physical_material_type['desc'], item.public_note,
      item.library_name].compact_blank.join(' - '), item.item_data['pid']]
  end
end
