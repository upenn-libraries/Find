# frozen_string_literal: true

describe Hathi::Service do
  include FixtureHelpers

  let(:record) { described_class.record(identifier_map: identifier_map) }

  before do
    allow(described_class).to receive(:hathi_response).with(identifier_map).and_return(response)
  end

  context 'with a single identifier' do
    let(:identifier_map) { { oclc: '3644448' } }

    context 'when a Hathi record is present' do
      let(:response) do
        JSON.parse(json_fixture('single_id_response', directory: :hathi))
      end

      it 'returns the record' do
        expect(record).to eq(JSON.parse(json_fixture('single_id_record', directory: :hathi)))
      end
    end

    context 'when a Hathi record is not present' do
      let(:response) do
        { 'oclc:3644448' => { 'records' => [], 'items' => [] } }
      end

      it 'returns an empty record' do
        expect(record).to eq({ 'records' => [], 'items' => [] })
      end
    end
  end

  context 'with multiple identifiers' do
    let(:identifier_map) { { oclc: '1259467', lccn: '10022969' } }

    context 'when a Hathi record is present' do
      let(:response) do
        JSON.parse(json_fixture('multi_id_response', directory: :hathi))
      end

      it 'returns the record' do
        expect(record).to eq(JSON.parse(json_fixture('multi_id_record', directory: :hathi)))
      end
    end

    context 'when a Hathi record is not present' do
      let(:response) do
        { 'oclc:1259467;lccn:10022969' => { 'records' => [], 'items' => [] } }
      end

      it 'returns an empty record' do
        expect(record).to eq({ 'records' => [], 'items' => [] })
      end
    end
  end
end
