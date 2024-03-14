# frozen_string_literal: true

describe Alert do
  it 'requires a valid on value' do
    alert = build(:alert, on: nil)
    expect(alert.valid?).to be false
    expect(alert.errors[:on].join).to include 'is not included'
  end

  it 'requires valid text if on is true' do
    alert = build(:alert, on: true, text: '')
    expect(alert.valid?).to be false
    expect(alert.errors[:text].join).to include "can't be blank"
  end

  it 'does not require text if on is false' do
    alert = build(:alert, on: false, text: '')
    expect(alert.valid?).to be true
  end

  it 'limits amount of alerts' do
    create_list(:alert, 2)
    alert = build(:alert)
    expect(alert.valid?).to be false
    expect(alert.errors[:base].join).to include 'count exceeded'
  end

  it 'sanitizes incoming HTML' do
    alert = create(:alert, text: '<script>This is a test!</script>')
    expect(alert.text).to eq 'This is a test!'
  end
end
