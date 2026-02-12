# frozen_string_literal: true

describe Discover::Artifact do
  it 'requires a title' do
    artwork = build(:artifact, title: nil)
    expect(artwork.valid?).to be false
    expect(artwork.errors[:title]).to include("can't be blank")
  end

  it 'requires a link' do
    artwork = build(:artifact, link: nil)
    expect(artwork.valid?).to be false
    expect(artwork.errors[:link]).to include("can't be blank")
  end

  describe '.search' do
    let!(:statue) { create(:artifact, location: 'America') }
    let!(:brick) do
      create(:artifact, title: 'Brick',
                        format: 'Clay',
                        description: 'This is an amazing clay brick',
                        location: 'Near Eastern',
                        on_display: true)
    end
    let!(:stela) do
      create(:artifact,
             title: 'Stela',
             format: 'Limestone',
             description: 'CBS Register: piece of blue grey limestone. Stela or Plaque.',
             location: 'Near Eastern',
             on_display: false)
    end

    context 'when the query fully matches a single artifact' do
      it 'returns the expected artifact' do
        expect(described_class.search('statue fragment')).to contain_exactly(statue)
      end
    end

    context 'when the query partially matches a single artifact' do
      it 'returns the expected artifact' do
        expect(described_class.search('clay')).to contain_exactly(brick)
      end
    end

    context 'when the query fully matches multiple artifacts' do
      it 'returns the expected artifacts' do
        expect(described_class.search('near eastern')).to contain_exactly(brick, stela)
      end
    end

    context 'when the query is in a different case' do
      it 'performs a case insensitive search' do
        expect(described_class.search('LIMESTONE')).to contain_exactly(stela)
      end
    end

    context 'when the query matches multiple artifacts with varying degrees of relevancy' do
      it 'returns artifacts sorted by relevancy' do
        expect(described_class.search('brick stela')).to eq [brick, stela]
      end
    end

    context 'when the query has no matching artifacts' do
      it 'returns no artifacts' do
        expect(described_class.search('Salvador Dali')).to eq []
      end
    end

    context 'when the query is blank' do
      it 'returns no artifacts' do
        expect(described_class.search('')).to eq []
      end
    end

    context "when the query is '*'" do
      it 'does not return all artifacts' do
        expect(described_class.search('*')).to eq []
      end
    end
  end
end
