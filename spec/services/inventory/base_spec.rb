# frozen_string_literal: true

describe Inventory::Base do
  describe '#to_h' do
    let(:inventory) do
      described_class.new('id', {})
    end

    it 'returns formatted hash' do
      expect(inventory.to_h).to eq({ count: nil, description: nil, format: nil,
                                     href: nil, id: nil, location: nil, policy: nil,
                                     status: nil, type: nil })
    end
  end
end
