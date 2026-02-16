# frozen_string_literal: true

describe Discover::Harvest do
  describe 'validations' do
    it 'is invalid without a source' do
      harvest = build(:harvest, source: nil)

      expect(harvest).not_to be_valid
      expect(harvest.errors[:source]).to include("can't be blank")
    end

    it 'validates uniqueness of source' do
      create(:harvest, source: 'penn_museum')
      duplicate_source = build(:harvest, source: 'penn_museum')

      expect(duplicate_source).not_to be_valid
      expect(duplicate_source.errors[:source]).to include('has already been taken')
    end
  end

  describe '#headers' do
    it 'returns expected http headers' do
      harvest = build(:harvest)
      expect(harvest.headers).to eq({ 'If-None-Match': harvest.etag,
                                      'If-Modified-Since': harvest.resource_last_modified.httpdate })
    end
  end

  describe '#update_from_response_headers!' do
    it 'updates harvest from response headers' do
      harvest = create(:harvest)
      headers = { 'last-modified' => DateTime.now, 'etag' => '123456' }
      harvest.update_from_response_headers!(headers)
      expect(harvest.resource_last_modified).to eq headers['last-modified']
      expect(harvest.etag).to eq headers['etag']
    end
  end
end
