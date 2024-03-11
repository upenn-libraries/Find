# frozen_string_literal: true

describe Alert do
  it 'requires a valid on value' do
    alert = build(:alert, on: nil)
    expect(alert.valid?).to be false
    expect(alert.errors[:on].join).to include 'is not included'
  end

  it 'requires valid text' do
    alert = build(:alert, text: nil)
    expect(alert.valid?).to be false
    expect(alert.errors[:text].join).to include "can't be blank"
  end

  it 'limits amount of alerts' do
    create_list(:alert, 2)
    alert = build(:alert)
    expect(alert.valid?).to be false
    expect(alert.errors[:base].join).to include 'count exceeded'
  end
end
