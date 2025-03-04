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

  describe '.search' do
    let!(:chair) { create(:art_work, location: 'Van Pelt Library') }
    let!(:moon_night) do
      create(:art_work, title: 'Moon Night',
                        link: 'https://pennartcollection.com/collection/art/1268/moon-night/',
                        thumbnail_url: 'https://pennartcollection.com/wp-content/themes/collection2015/images/objects/1268.thumb.jpg',
                        format: 'Lithograph',
                        creator: 'Yu, Chen',
                        description: 'This lithograph is by Chinese artist Chen Yu. The bright full moon illuminates ' \
'the horizon line and rippling waves as three cranes stand by, echoing the verticality of the reeds and their ' \
                          'reflections.',
                        location: 'Van Pelt Library')
    end
    let!(:fannie) do
      create(:art_work,
             title: 'Fannie',
             link: 'https://pennartcollection.com/collection/art/1177/fannie/',
             thumbnail_url: 'https://pennartcollection.com/wp-content/themes/collection2015/images/objects/1177.thumb.jpg',
             format: 'Lithograph',
             creator: 'Soyer, Raphael',
             description: 'Framing: Black wood frame with white window mat.',
             location: 'Van Pelt Library')
    end

    context 'when the query fully matches a single artwork' do
      it 'returns the expected artwork' do
        expect(described_class.search('chair')).to contain_exactly(chair)
      end
    end

    context 'when the query partially matches a single artwork' do
      it 'returns the expected artwork' do
        expect(described_class.search('reflect')).to contain_exactly(moon_night)
      end
    end

    context 'when the query fully matches multiple artworks' do
      it 'returns the expected artworks' do
        expect(described_class.search('lithograph')).to contain_exactly(moon_night, fannie)
      end
    end

    context 'when the query is in a different case' do
      it 'performs a case insensitive search' do
        expect(described_class.search('LITHOGRAPH')).to contain_exactly(moon_night, fannie)
      end
    end

    context 'when the query matches multiple artworks with varying degrees of relevancy' do
      it 'returns artworks sorted by relevancy' do
        expect(described_class.search('moon lithograph Van Pelt Library')).to eq [moon_night, fannie, chair]
      end
    end

    context 'when the query has no matching artwork' do
      it 'returns no artworks' do
        expect(described_class.search('Salvador Dali')).to eq []
      end
    end

    context 'when the query is blank' do
      it 'returns no artworks' do
        expect(described_class.search('')).to eq []
      end
    end

    context "when the query is '*'" do
      it 'does not return all artworks' do
        expect(described_class.search('*')).to eq []
      end
    end
  end
end
