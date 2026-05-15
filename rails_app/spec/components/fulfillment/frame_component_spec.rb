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

  it 'renders a lazy fulfillment form frame with correct attributes' do
    expect(rendered).to have_text I18n.t('requests.form.heading')
  end

  it 'renders placeholder skeleton content before the frame loads' do
    expect(rendered).to have_selector('.placeholder-glow')
    expect(rendered).to have_button I18n.t('requests.form.buttons.placeholder'), disabled: true
  end
end
