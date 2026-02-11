# frozen_string_literal: true

describe Discover::Record do
  let(:record) { build(:discover_record, :with_thumbnail) }

  it 'returns an array for title' do
    expect(record.title).to be_an Array
  end

  it 'returns an array for creator' do
    expect(record.creator).to be_an Array
  end

  it 'returns an array for formats' do
    expect(record.formats).to be_an Array
  end

  it 'returns an array for location' do
    expect(record.location).to be_an Array
  end

  it 'returns an array for publication' do
    expect(record.publication).to be_an Array
  end

  it 'returns an array for description' do
    expect(record.description).to be_an Array
  end

  it 'returns a string for link_url' do
    expect(record.link_url).to be_a String
  end

  it 'returns a string for thumbnail_url' do
    expect(record.thumbnail_url).to be_a String
  end
end
