# frozen_string_literal: true

describe Home::IntroArtComponent, type: :components do
  let(:name) { Settings.home_intro_art.active }
  let(:art) { Settings.home_intro_art.options[name] }
  let(:rendered) { render_inline(described_class.new) }
  let(:image) { rendered.css('img.fi-intro__art').first }

  it 'renders a picture with a wider crop for very wide screens' do
    source = rendered.css('picture source').first
    expect(source['media']).to eq described_class::WIDE_MEDIA
    expect(source['srcset']).to include art.wide_region
  end

  it 'falls back to the standard crop' do
    expect(image['src']).to include art.region
    expect(image['src']).to start_with Settings.iiif_image_base_url
  end

  it 'offers the standard crop at each configured width' do
    described_class::WIDTHS.each do |width|
      expect(image['srcset']).to include "#{width},/0/default.jpg #{width}w"
    end
  end

  it 'names the treatment the config asked for, so the stylesheet can handle it' do
    expect(image['class']).to include "fi-intro__art--#{art.treatment}"
  end

  it 'describes the picture' do
    expect(image['alt']).to eq I18n.t("home.intro_art.#{name}.alt")
  end

  it 'credits the source' do
    expect(rendered).to have_link(I18n.t("home.intro_art.#{name}.caption"), href: art.source_url)
  end

  context 'when the named art is not configured' do
    let(:rendered) { render_inline(described_class.new(name: 'nonesuch')) }

    it 'renders nothing rather than a broken picture' do
      expect(rendered.to_html).to be_blank
    end
  end
end
