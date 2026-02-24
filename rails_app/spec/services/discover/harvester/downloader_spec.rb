# frozen_string_literal: true

describe Discover::Harvester::Downloader do
  include FixtureHelpers
  include Discover::ApiMocks::Harvester::PennMuseum

  let(:downloader) do
    base_url = URI::HTTPS.build(host: Settings.discover.source.penn_museum.host)
    described_class.new(connection: Discover::Harvester::Connection.new(base_url: base_url))
  end

  describe '#download' do
    let(:csv) { tabular_fixture('penn_museum', namespace: :discover) }
    let(:response_headers) { { 'last-modified' => 'yesterday', 'etag' => '"123456"' } }
    let(:request_headers) { { 'If-None-Match' => '123456', 'If-Modified-Since' => 'yesterday' } }
    let(:result) do
      downloader.download(path: Settings.discover.source.penn_museum.csv.path,
                          headers: request_headers,
                          filename: 'penn_museum', extension: '.csv')
    end

    context 'when the download succeeds' do
      before { stub_csv_download_response(status: 200, body: csv, response_headers: response_headers) }

      it 'returns an array with the response and tempfile' do
        faraday_response, tempfile = result
        expect(faraday_response).to be_a Faraday::Response
        expect(tempfile).to be_a Tempfile
      end

      it 'returns a tempfile with the expected contents' do
        _faraday_response, tempfile = result
        expect(tempfile.read).to eq csv
      end

      it 'returns a tempfile with the expected filename' do
        _faraday_response, tempfile = result
        basename = File.basename(tempfile.path)
        extension = File.extname(tempfile.path)
        expect(basename).to match(/penn_museum/)
        expect(extension).to eq '.csv'
      end

      it 'makes a request with the expected headers' do
        faraday_response, _tempfile = result
        faraday_request_headers = faraday_response.env.request_headers
        expect(faraday_request_headers).to include request_headers
      end
    end

    context 'when the download fails' do
      context 'with a created temp file' do
        before do
          stub_csv_download_response(status: 200, body: csv, response_headers: response_headers)
        end

        it 'raises an error and cleans up the tempfile if it has been created' do
          tempfile = Tempfile.new('test')
          allow(Tempfile).to receive(:new).and_return(tempfile)
          allow(tempfile).to receive(:write).and_raise('write failure')
          expect {
            downloader.download(path: Settings.discover.source.penn_museum.csv.path,
                                headers: request_headers,
                                filename: 'penn_museum', extension: '.csv')
          }.to raise_error('write failure')
          expect(tempfile.closed?).to be true
        end
      end
    end

    context 'when the file has not changed (304 response)' do
      before do
        stub_csv_download_response(status: 304, body: '', response_headers: response_headers)
      end

      it 'returns nil instead of a tempfile' do
        faraday_response, tempfile = result
        expect(faraday_response).to be_a Faraday::Response
        expect(tempfile).to be_a NilClass
      end
    end
  end
end
