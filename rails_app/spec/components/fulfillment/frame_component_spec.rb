# frozen_string_literal: true

describe Fulfillment::FrameComponent, type: :components do
  subject(:rendered) do
    render_inline(
      described_class.new(
        form_params: {
          mms_id: '9913203433503681',
          holding_id: '1234',
          host_record_id: nil,
          location_code: 'scrare'
        }
      )
    )
  end

  it 'renders a lazy fulfillment form frame' do
    expect(rendered).to have_selector("turbo-frame#form_frame[src*='#{fulfillment_form_path}']", visible: :all)
    expect(rendered).to have_text I18n.t('requests.form.heading')
  end
end
