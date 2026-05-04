# frozen_string_literal: true

describe Fulfillment::FrameComponent, type: :components do
  subject(:rendered) do
    render_inline(
      described_class.new(mms_id: mms_id,
                          holding_id: holding_id,
                          host_record_id: host_record_id,
                          location_code: location_code)
    )
  end

  let(:mms_id) { '9913203433503681' }
  let(:holding_id) { '1234' }
  let(:host_record_id) { nil }
  let(:location_code) { 'scrare' }

  it 'renders a lazy fulfillment form frame' do
    expect(rendered).to have_selector("turbo-frame#form_frame[src*='#{fulfillment_form_path}']", visible: :all)
    expect(rendered).to have_text I18n.t('requests.form.heading')
  end
end
