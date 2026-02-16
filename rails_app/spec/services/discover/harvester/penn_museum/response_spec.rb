# frozen_string_literal: true

describe Discover::Harvester::PennMuseum::Response do
  let(:headers) { { 'last-modified' => 'yesterday', 'etag' => '"123456"', 'excluded-header' => 'ignore' } }
  let(:faraday_response) { instance_double(Faraday::Response, status: 200, headers: headers, success?: true) }
  let(:harvest_response) { described_class.new(response: faraday_response) }

  describe '.not_modified?' do
    context 'with a 304 status code' do
      it 'return true' do
        expect(described_class.not_modified?(304)).to be true
      end
    end

    context 'without a 304 status code' do
      it 'return true' do
        expect(described_class.not_modified?(300)).to be false
      end
    end
  end

  describe '.last_modified' do
    let(:headers) { { 'last-modified'=> 'yesterday' } }

    it 'returns last modified header' do
      expect(harvest_response.last_modified).to eq 'yesterday'
    end
  end

  describe '.etag' do
    let(:headers) { { 'etag'=> '"123456"' } }

    it 'returns etag' do
      expect(harvest_response.etag).to eq '"123456"'
    end
  end

  describe '.headers' do
    it 'returns the desired headers' do
      expect(harvest_response.headers).to eq({ 'last-modified' => 'yesterday', 'etag' => '"123456"' })
    end
  end

  it 'delegates to Faraday::Response' do
    expect(harvest_response.success?).to be true
  end
end
