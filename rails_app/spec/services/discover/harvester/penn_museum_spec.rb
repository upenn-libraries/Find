# frozen_string_literal: true

describe Discover::Harvester::PennMuseum do
  include FixtureHelpers
  include Discover::ApiMocks::Harvester::PennMuseum

  let(:harvester) { described_class.new }

  describe '#download' do
    let(:csv) { File.read('spec/fixtures/discover/csv/penn_museum.csv') }
    let(:headers) { { 'last-modified' => 'yesterday', 'etag' => '"123456"' } }

    context 'with no block given' do
      it 'raises an ArgumentError' do
        expect {
          harvester.download
        }.to raise_error(described_class::Error, I18n.t('discover.harvesters.penn_museum.errors.argument'))
      end
    end

    context 'when the download is successful (2XX response)' do
      before do
        stub_csv_download_response(status: 200, body: csv, headers: headers)
      end

      it 'yields the rewound file to the block' do
        yielded_content = nil
        harvester.download do |file|
          yielded_content = file.read
        end
        expect(yielded_content).to eq(csv)
      end

      it 'returns a successful response' do
        response = harvester.download { |_f| }
        expect(response).to be_a Discover::Harvester::PennMuseum::Response
        expect(response.success?).to be true
      end

      it 'returns a response with the correct headers' do
        response = harvester.download { |_f| }
        expect(response.headers).to eq headers
      end

      it 'cleans up the file after the block has finished processing' do
        cached_file = nil
        harvester.download do |file|
          cached_file = file
        end
        expect(cached_file.closed?).to be true
      end
    end

    context 'when the file has not changed (304 response)' do
      before do
        stub_csv_download_response(status: 304, body: '', headers: headers)
      end

      it 'does not yield the file to the block' do
        expect { |block| harvester.download(&block) }.not_to yield_control
      end

      it 'returns an unsuccessful response' do
        result = harvester.download { |_f| }
        expect(result.success?).to be false
      end

      it 'returns a response with the correct headers' do
        response = harvester.download { |_f| }
        expect(response.headers).to eq headers
      end
    end

    context 'when the download fails' do
      context 'without creating a temp file' do
        before do
          stub_csv_download_response(status: 500, body: '', headers: {})
        end

        it 'raises an error' do
          error_message = I18n.t('discover.harvesters.penn_museum.errors.download',
                                 error: 'the server responded with status 500')
          expect { harvester.download { |_f| } }.to raise_error(described_class::Error, error_message)
        end
      end

      context 'with a created temp file' do
        let(:headers) { {} }
        let(:tempfile) { Tempfile.new('test') }

        before do
          allow(Tempfile).to receive(:new).and_return(tempfile)
          allow(tempfile).to receive(:write).and_raise('write failure')
          stub_csv_download_response(status: 200, body: csv, headers: headers)
        end

        it 'raises an error' do
          error_message = I18n.t('discover.harvesters.penn_museum.errors.download', error: 'write failure')
          expect { harvester.download { |_f| } }.to raise_error(described_class::Error, error_message)
        end

        it 'cleans up the tempfile if it has been created' do
          path = tempfile.path
          harvester.download { |_f| }
        rescue StandardError => _e
          expect(tempfile.closed?).to be true
          expect(File.exist?(path)).to be false
        end
      end
    end
  end
end
