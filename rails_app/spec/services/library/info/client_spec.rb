# frozen_string_literal: true

describe Library::Info::Client do
  describe '.create' do
    context 'with a successful connection' do
      it 'returns a Faraday::Connection' do
        expect(described_class.connection).to be_a Faraday::Connection
      end
    end
  end
end