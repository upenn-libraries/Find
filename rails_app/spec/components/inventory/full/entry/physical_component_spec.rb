# frozen_string_literal: true

describe Inventory::Full::Entry::PhysicalComponent, type: :components do
  subject(:rendered) { render_inline(described_class.new(entry: entry)) }

  context 'with an Aeon entry' do
    let(:entry) do
      create(:physical_entry, mms_id: '9913203433503681', holding_id: '1234', location_code: 'scrare')
    end

    it 'renders the fulfillment frame immediately' do
      expect(rendered).to have_selector(
        "turbo-frame#form_frame[src*='#{fulfillment_form_path}']",
        visible: :all
      )
      expect(rendered).to have_text I18n.t('requests.form.heading')
    end

    it 'does not render a request disclosure' do
      expect(rendered).to have_no_selector('details.fulfillment > summary',
                                           text: I18n.t('requests.form.request_item'))
    end
  end
end
