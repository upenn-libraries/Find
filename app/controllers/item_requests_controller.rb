# frozen_string_literal: true

# Item requesting controller
class ItemRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_item_labels

  def new; end

  private

  def set_item_labels
    items = Alma::BibItem.find(params[:mms_id], holding_id: params[:holding_id])
    @item_labels = items.filter_map { |item| item_label(item) }.sort
  end

  def item_label(item)
    [item.description, item.physical_material_type['desc'], item.public_note, item.library_name]
      .compact_blank.join(' - ')
  end
end
