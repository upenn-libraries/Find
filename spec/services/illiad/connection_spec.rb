# frozen_string_literal: true

describe Illiad::Connection do
  describe '.create' do
    it 'returns a Faraday::Connection' do
      expect(described_class.create).to be_a Faraday::Connection
    end
  end

  describe '.error_messages' do
    let(:response) { build(:illiad_api_error_response) }
    let(:error) { Faraday::Error.new(nil, { body: response }) }

    context 'with an error message from illiad api' do
      it 'returns expected error message' do
        expect(described_class.error_messages(error: error))
          .to eq("#{described_class::ERROR_MESSAGE} #{response['Message']}")
      end
    end

    context 'with multiple error messages from illiad api' do
      let(:response) { build(:illiad_api_error_response, :with_model_error) }

      it 'returns expected error message' do
        model_errors = response['ModelState']['model'].join('').strip
        expect(described_class.error_messages(error: error))
          .to eq("#{described_class::ERROR_MESSAGE} #{response['Message']} #{model_errors}")
      end
    end

    context 'without an error message from illiad api' do
      let(:error) { Faraday::Error.new(nil, nil) }

      it 'returns expected the default error message' do
        expect(described_class.error_messages(error: error))
          .to eq(described_class::ERROR_MESSAGE)
      end
    end
  end
end
