# frozen_string_literal: true

describe Discover::Record do
  let(:record) { build(:discover_record, :with_thumbnail) }

  it 'returns an array for title' do
    expect(record.title).to contain_exactly 'Title'
  end

  it 'returns an array for creator' do
    expect(record.creator).to contain_exactly 'Record Creator'
  end

  it 'returns an array for formats' do
    expect(record.formats).to contain_exactly 'Record Format'
  end

  it 'returns an array for location' do
    expect(record.location).to contain_exactly 'Record Location'
  end

  it 'returns an array for publication' do
    expect(record.publication).to contain_exactly('Record Publication Date', 'Record Publication Place')
  end

  it 'returns an array for description' do
    expect(record.description).to contain_exactly 'Record Description'
  end

  it 'returns a string for link_url' do
    expect(record.link_url).to eq 'https://www.test.com/record'
  end

  it 'returns a string for thumbnail_url' do
    expect(record.thumbnail_url).to eq 'https://www.file.com/thumbnail.jpg'
  end
end
