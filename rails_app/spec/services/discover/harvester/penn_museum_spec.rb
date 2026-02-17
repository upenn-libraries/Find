# frozen_string_literal: true

describe Discover::Harvester::PennMuseum do
  include FixtureHelpers
  include Discover::ApiMocks::Harvester::PennMuseum

  let(:harvester) { described_class.new }

  describe '#harvest' do
    let(:csv) { csv_fixture('penn_museum', namespace: :discover) }
    let(:headers) { { 'last-modified' => 'yesterday', 'etag' => '"123456"' } }

    context 'with no block given' do
      it 'raises an ArgumentError' do
        expect {
          harvester.harvest
        }.to raise_error(ArgumentError, I18n.t('discover.harvesters.penn_museum.errors.argument'))
      end
    end

    context 'when the download is successful (2XX response)' do
      before do
        stub_csv_download_response(status: 200, body: csv, response_headers: headers)
      end

      it 'yields the rewound file to the block' do
        yielded_content = nil
        harvester.harvest do |file|
          yielded_content = file.read
        end
        expect(yielded_content).to eq(csv)
      end

      it 'returns a successful response' do
        response = harvester.harvest { |_f| }
        expect(response).to be_a Discover::Harvester::Response
        expect(response.success?).to be true
      end

      it 'returns a response with the correct headers' do
        response = harvester.harvest { |_f| }
        expect(response.headers).to eq headers
      end

      it 'cleans up the file after the block has finished processing' do
        cached_file = nil
        harvester.harvest do |file|
          cached_file = file
        end
        expect(cached_file.closed?).to be true
      end
    end

    context 'when the file has not changed (304 response)' do
      before do
        stub_csv_download_response(status: 304, body: '', response_headers: headers)
      end

      it 'does not yield the file to the block' do
        expect { |block| harvester.harvest(&block) }.not_to yield_control
      end

      it 'returns an unsuccessful response' do
        response = harvester.harvest { |_f| }
        expect(response.success?).to be false
      end

      it 'returns a response with the correct headers' do
        response = harvester.harvest { |_f| }
        expect(response.headers).to eq headers
      end
    end
  end
end
