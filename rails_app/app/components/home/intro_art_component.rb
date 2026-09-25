# frozen_string_literal: true

module Home
  # MOCKUP: art for the page intro under the header, ported from the design system docs
  # (docs-page.njk bandArt). A IIIF image cropped to a wide strip, with a wider crop for very wide
  # screens, and a
  # caption crediting the source.
  #
  # Mirrors Finding Aids' HeroPictureComponent: the picture is assembled with Rails helpers rather
  # than written out as markup, so the IIIF urls are built in one place and can be tested.
  #
  # See the `home_intro_art` config for the shape this expects, and config/locales for the alt text
  # and caption under `home.intro_art.<name>`.
  class IntroArtComponent < Blacklight::Component
    # The art sits in the intro's right portion, so it never needs more than half the viewport
    SIZES = '50vw'

    # Past this, the intro is wide enough that the taller crop reads better
    WIDE_MEDIA = '(min-width: 100em)'

    WIDE_WIDTHS = [1000, 1500].freeze
    WIDTHS = [800, 1200, 1600].freeze

    attr_reader :name, :art

    # @param name [String] which of the configured options to render
    def initialize(name: Settings.home_intro_art.active)
      @name = name
      @art = Settings.home_intro_art.options[name]
    end

    def render?
      art.present?
    end

    def call
      tag.figure(class: 'fi-intro__figure') { safe_join([picture, caption]) }
    end

    private

    # @return [String]
    def picture
      picture_tag do
        safe_join([tag.source(srcset: srcset(art.wide_region, WIDE_WIDTHS), media: WIDE_MEDIA, sizes: SIZES),
                   default_image])
      end
    end

    # The crop every screen falls back to. Its treatment class is named by the config: a pale pencil
    # sketch needs different handling from a painting.
    # @return [String]
    def default_image
      image_tag iiif_url(art.region, WIDTHS.first),
                class: ['fi-intro__art', "fi-intro__art--#{art.treatment}"],
                srcset: srcset(art.region, WIDTHS),
                sizes: SIZES,
                alt: t("home.intro_art.#{name}.alt")
    end

    # In the hero pattern's style: a short source link along the intro's bottom edge
    # @return [String]
    def caption
      tag.figcaption(class: 'fi-intro__caption') do
        tag.div(class: 'pl-viewport-margins') do
          tag.span(class: 'fi-intro__caption-text') do
            link_to t("home.intro_art.#{name}.caption"), art.source_url
          end
        end
      end
    end

    # @param region [String] an IIIF region, such as a percentage crop
    # @param widths [Array<Integer>]
    # @return [String] urls formatted for a srcset attribute
    def srcset(region, widths)
      widths.map { |width| "#{iiif_url(region, width)} #{width}w" }.join(', ')
    end

    # IIIF Image API 3: {base}/{id}/{region}/{size}/{rotation}/{quality}.{format}
    # @return [String]
    def iiif_url(region, width)
      "#{Settings.iiif_image_base_url}/#{art.uuid}/#{region}/#{width},/0/default.jpg"
    end
  end
end
