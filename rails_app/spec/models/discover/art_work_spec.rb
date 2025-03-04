# frozen_string_literal: true

describe Discover::ArtWork do
  it 'requires a title' do
    artwork = build(:art_work, title: nil)
    expect(artwork.valid?).to be false
    expect(artwork.errors[:title]).to include("can't be blank")
  end

  it 'requires a link' do
    artwork = build(:art_work, link: nil)
    expect(artwork.valid?).to be false
    expect(artwork.errors[:link]).to include("can't be blank")
  end
end
