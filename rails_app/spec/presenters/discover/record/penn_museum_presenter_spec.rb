# frozen_string_literal: true

describe Discover::Record::PennMuseumPresenter do
  let(:presenter) { described_class.new(record: record) }

  describe '#title' do
    context 'with comma separated string' do
      let(:record) { build(:discover_record, :from_museum, title: ['title1,title2']) }

      it 'joins with comma and whitespace for display' do
        expect(presenter.title).to eq('title1, title2')
      end
    end
  end

  describe '#formats' do
    context 'with comma separated string' do
      let(:record) { build(:discover_record, :from_museum, body: { format: ['vellum,mother-of-pearl'] }) }

      it 'joins with comma and whitespace for display' do
        expect(presenter.formats).to eq('vellum, mother-of-pearl')
      end
    end
  end

  describe '#location' do
    context 'when location does not have a mapped section' do
      let(:record) { build(:discover_record, :from_museum, body: { location: ['Mediterranean'] }) }

      it 'returns the expected location' do
        expect(presenter.location).to eq('Mediterranean Section')
      end
    end

    context 'when location has a mapped section' do
      let(:record) { build(:discover_record, :from_museum, body: { location: ['Historic'] }) }

      it 'returns the expected location' do
        expect(presenter.location).to eq('Historical Archaeology Section')
      end
    end
  end
end
