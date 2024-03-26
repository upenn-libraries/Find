# frozen_string_literal: true

# Item requesting controller
class ItemRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mms_id
  before_action :set_item_labels, only: %w[new]
  before_action :set_locations, only: %w[new]

  SKIPPED_LIBRARIES = %w[EMPTY ZUnavailable].freeze

  def new; end

  def submit
    flash[:notice] = 'Requesting submission needs to be implemented.'
    redirect_to solr_document_path(id: @mms_id)
  end

  private

  def set_mms_id
    @mms_id = params[:mms_id]
  end

  def set_item_labels
    items = Alma::BibItem.find(params[:mms_id], holding_id: params[:holding_id])
    @item_labels = items.filter_map { |item| item_label(item) }.sort
  end

  def set_locations
    @locations = Alma::Library.all.filter_map do |library|
      next if SKIPPED_LIBRARIES.include? library.code

      [library.name, library.code]
    end
  end

  def item_label(item)
    [item.description, item.physical_material_type['desc'], item.public_note, item.library_name]
      .compact_blank.join(' - ')
  end
end
