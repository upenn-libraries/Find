# frozen_string_literal: true

require 'rails_helper'

describe FulfillmentController do
  describe 'GET #form' do
    let(:item) { build(:item, :aeon_location) }

    before do
      allow(Inventory::Item).to receive(:find_all).and_return([item])
    end

    it 'renders an Aeon link that includes an escaped title parameter' do
      get fulfillment_form_path, params: {
        mms_id: '9913203433503681',
        holding_id: '1234',
        location_code: 'scrare'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(CGI.escape(item.bib_data['title']))
    end
  end
end
