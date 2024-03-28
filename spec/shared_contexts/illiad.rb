# frozen_string_literal: true

HTTP_METHODS = %i[get post put].freeze

shared_context 'with stubbed illiad request data' do
  before do
    connection = instance_double(Faraday::Connection)
    response = instance_double(Faraday::Response)
    allow(Faraday).to receive(:new).and_return(connection)
    allow(connection).to receive_messages(HTTP_METHODS.index_with { response })
    allow(response).to receive(:body).and_return(illiad_response_data)
  end
end

shared_context 'with stubbed illiad api error' do
  before do
    connection = instance_double(Faraday::Connection)
    allow(Faraday).to receive(:new).and_return(connection)
    HTTP_METHODS.each do |method|
      allow(connection).to receive(method).and_raise(Faraday::Error)
    end
  end
end
