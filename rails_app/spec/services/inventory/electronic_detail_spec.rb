# frozen_string_literal: true

describe Inventory::ElectronicDetail do
  let(:electronic_detail) do
    described_class.new(mms_id: '9977568423203681', portfolio_id: '53671045450003681',
                        collection_id: '61468379530003681')
  end

  describe '#notes' do
    let(:notes) { electronic_detail.notes }
    let(:portfolio) do
      { 'public_note' => 'portfolio', 'authentication_note' => 'portfolio',
        'electronic_collection' => { 'service' => { 'value' => '62468379520003681' } } }
    end
    let(:service) { { 'public_note' => 'service', 'authentication_note' => 'service' } }
    let(:collection) { { 'public_note' => 'collection', 'authentication_note' => 'collection' } }

    before do
      allow(electronic_detail).to receive(:portfolio).and_return(portfolio)
      allow(electronic_detail).to receive(:collection).and_return(collection)
      allow(electronic_detail).to receive(:service).and_return(service)
    end

    context 'when notes are found in portfolio' do
      it 'returns expected values' do
        expect(notes).to contain_exactly(portfolio['public_note'], portfolio['authentication_note'])
      end

      it 'does not make additional api requests' do
        notes
        expect(electronic_detail).not_to have_received(:service)
        expect(electronic_detail).not_to have_received(:collection)
      end
    end

    context 'when notes are missing from portfolio but found in service' do
      let(:portfolio) do
        { 'public_note' => '', 'authentication_note' => 'portfolio',
          'electronic_collection' => { 'service' => { 'value' => 'service_id' } } }
      end

      it 'returns expected values' do
        expect(notes).to contain_exactly(service['public_note'], portfolio['authentication_note'])
      end

      it 'only makes necessary api requests' do
        notes
        expect(electronic_detail).to have_received(:service).once
        expect(electronic_detail).not_to have_received(:collection)
      end
    end

    context 'when notes are found only in collection' do
      let(:portfolio) do
        { 'public_note' => '', 'authentication_note' => '',
          'electronic_collection' => { 'service' => { 'value' => 'service_id' } } }
      end
      let(:service) { { 'public_note' => '', 'authentication_note' => '' } }

      it 'returns expected values' do
        expect(notes).to contain_exactly(*collection.values)
      end

      it 'makes all api requests' do
        notes
        expect(electronic_detail).to have_received(:portfolio).twice
        expect(electronic_detail).to have_received(:service).once
      end
    end

    context 'when there is no collection id' do
      let(:electronic_detail) do
        described_class.new(mms_id: '9977568423203681', portfolio_id: '53671045450003681',
                            collection_id: '')
      end

      it 'only fetches notes from portfolio' do
        expect(notes).to contain_exactly(portfolio['public_note'], portfolio['authentication_note'])
      end
    end

    context 'when notes are scattered' do
      let(:portfolio) do
        { 'public_note' => 'portfolio', 'authentication_note' => '',
          'electronic_collection' => { 'service' => { 'value' => '62468379520003681' } } }
      end
      let(:service) { { 'public_note' => 'service', 'authentication_note' => '' } }
      let(:collection) { { 'public_note' => 'collection', 'authentication_note' => 'collection' } }

      it 'returns expected values' do
        expect(notes).to contain_exactly(portfolio['public_note'], collection['authentication_note'])
      end
    end
  end
end
