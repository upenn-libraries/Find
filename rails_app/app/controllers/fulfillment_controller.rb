# frozen_string_literal: true

# Fulfillment controller used to power turboframes that generate the inline requesting form.
class FulfillmentController < ApplicationController
  # Returns form with item select dropdown and sets up turbo frame for displaying options.
  # GET /fulfillment/form?mms_id=XXXX&holding_id=XXXX
  def form
    items = Inventory::Item.find_all(mms_id: params[:mms_id],
                                     holding_id: params[:holding_id],
                                     host_record_id: params[:host_record_id],
                                     location_code: params[:location_code])

    # Ensuring we send holding identifier to the fulfillment form in cases where a holding identifier is not present.
    # Holding identifiers are not received from the availability api if an item is in a temporary location.
    render(Fulfillment::FormComponent.new(mms_id: params[:mms_id],
                                          holding_id: params[:holding_id] || items.first.holding_id,
                                          items: items,
                                          user: current_user), layout: false)
  end

  # Return fulfillment options based on mms id/holding id/item id. Options are dependent
  # on properties of an item and user group. Returns a rendered OptionsComponent which uses
  # those options to determine what actions are available to the user.
  # GET /fulfillment/options
  def options
    item = Inventory::Item.find(mms_id: params[:mms_id], holding_id: params[:holding_id], item_id: params[:item_id])

    render(Fulfillment::OptionsComponent.new(user: current_user, item: item), layout: false)
  end
end
