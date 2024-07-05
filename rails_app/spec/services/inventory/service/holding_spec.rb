# frozen_string_literal: true

describe Inventory::Service::Holding do
  let(:mms_id) { '123456' }
  let(:holding_id) { '78910' }
  let(:service_holding) { Inventory::Service::Physical.holding(mms_id: mms_id, holding_id: holding_id) }
  let(:holding) { build :holding }

  before do
    allow(Alma::BibHolding).to receive(:find).and_return(holding)
  end

  it 'returns the public note value' do
    expect(holding.public_note).to eq 'Not currently received.'
  end
end
