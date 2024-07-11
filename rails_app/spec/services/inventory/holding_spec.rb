# frozen_string_literal: true

describe Inventory::Holding do
  let(:holding) { described_class.find(mms_id: '123', holding_id: '456') }

  before do
    allow(Alma::BibHolding).to receive(:find).and_return(build(:holding).bib_holding)
  end

  describe '.find' do
    it 'returns a Holding' do
      expect(holding).to be_a described_class
    end
  end

  describe '#notes' do
    it 'returns public note values from the parsed MARC' do
      expect(holding.notes).to eq ['Public note']
    end
  end

  describe '#marc' do
    it 'returns a MARC::Record object' do
      expect(holding.marc).to be_a MARC::Record
    end
  end
end
