# frozen_string_literal: true

describe Illiad::Connection do
  let(:illiad_api_wrapper_class) { Class.new { extend(Illiad::Connection) } }
  let(:illiad_error) do
    {
      "Message": 'The request is invalid.',
      "ModelState": {
        "model.ProcessType": [
          'The ProcessType property is required.'
        ]
      }
    }
  end

  describe '.faraday' do
    it 'returns a Faraday::Connection' do
      expect(illiad_api_wrapper_class.faraday).to be_a Faraday::Connection
    end
  end
end
