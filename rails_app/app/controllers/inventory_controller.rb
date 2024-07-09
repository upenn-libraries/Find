# frozen_string_literal: true

# Inventory controller used to power turboframes that make calls to lazy load additional information.
class InventoryController < ApplicationController
  include Blacklight::Searchable

  delegate :blacklight_config, to: CatalogController

  before_action :load_document # Loading document for all actions to ensure the document is present in our instance.

  # GET /inventory/:id/brief
  # Returns brief inventory information for a record.
  def brief
    respond_to do |format|
      format.html { render(Inventory::BriefInventoryComponent.new(document: @document), layout: false) }
    end
  end

  # GET /inventory/:id/portfolio/:pid/collection/:cid/detail
  # Returns details for an electronic entry.
  def electronic_detail
    respond_to do |format|
      format.html do
        render(
          Inventory::ElectronicDetailComponent.new(
            detail: Inventory::Electronic.find(
              mms_id: params[:id], portfolio_id: params[:pid], collection_id: params[:cid]
            )
          ), layout: false
        )
      end
    end
  end

  private

  # Default to no search state.
  def search_state
    nil
  end

  def load_document
    @document = search_service.fetch(params[:id])
  end
end
