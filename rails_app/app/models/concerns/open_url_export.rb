# frozen_string_literal: true

# Methods that export OpenURL CTX KEV from MARC record
# In Franklin, this logic is included with the `blacklight-marc` gem,
# but we have extracted it into a concern to make it easier to maintain.
module OpenUrlExport
  extend ActiveSupport::Concern

  EXPORT_PREFIX = 'ctx_ver=Z39.88-2004&amp;rft_val_fmt=info%3Aofi%2Ffmt%3Akev%3Amtx%3A'
  EXPORT_POSTFIX = 'rfr_id=info%3Asid%2Frubygems.org%2Fgems%2Fblacklight%3Agenerator&amp;'

  # Extract values from MARC record using PennMARC parser
  # @param [Array<String>, String] format
  # @return [Hash]
  def marc_values(format:)
    { title: marc(:title_show),
      author: marc(:creator_authors_list, main_tags_only: true),
      corp_author: marc(:creator_corporate_search),
      publication_date: marc(:date_publication).year,
      publication_place: marc(:production_publication_ris_place_of_pub),
      publisher_name: marc(:production_publication_ris_publisher),
      publisher_info: marc(:production_publication_citation_show),
      edition: marc(:edition_show, with_alternate: false),
      isbn: marc(:identifier_isbn_show),
      issn: marc(:identifier_issn_show),
      format: normalize_format(format) }
  end

  # Export the current record as an OpenURL query string
  # @param [Array<String>, String, nil] format
  # @return [String]
  def export_as_openurl_ctx_kev(format = nil)
    case normalize_format(format)
    when 'book'
      "#{EXPORT_PREFIX}book&amp;#{EXPORT_POSTFIX}rft.genre=book&amp;" \
        "#{book_export_text(marc_values: marc_values(format: format)).to_query}"
    when /journal/i
      "#{EXPORT_PREFIX}journal&amp;#{EXPORT_POSTFIX}rft.genre=article&amp;" \
        "#{journal_export_text(marc_values: marc_values(format: format)).to_query}"
    else
      "#{EXPORT_PREFIX}dc&amp;#{EXPORT_POSTFIX}" \
      "#{default_export_text(marc_values: marc_values(format: format)).to_query}"
    end
  end

  private

  # Assemble OpenURL KEV hash for book format
  # @param [Hash] marc_values
  # @return [Hash]
  def book_export_text(marc_values:)
    { 'rft.btitle' => marc_values[:title],
      'rft.title' => marc_values[:title],
      # what to do when there are multiple values? join them? or just take the first one?
      # how do we know how to join them in a way that is compliant with citation standards?
      # blacklight-marc seems like it just takes the first value
      'rft.au' => marc_values[:author].first,
      'rft.aucorp' => marc_values[:corp_author].first,
      'rft.date' => marc_values[:publication_date],
      'rft.place' => marc_values[:publication_place].first,
      'rft.pub' => marc_values[:publisher_name].first,
      'rft.edition' => marc_values[:edition].first,
      'rft.isbn' => marc_values[:isbn].first }
  end

  # Assemble OpenURL KEV hash for journal format
  # @param [Hash] marc_values
  # @return [Hash]
  def journal_export_text(marc_values:)
    { 'rft.title' => marc_values[:title],
      'rft.atitle' => marc_values[:title],
      'rft.aucorp' => marc_values[:corp_author].first,
      'rft.date' => marc_values[:publication_date],
      'rft.issn' => marc_values[:issn].first }
  end

  # Assemble OpenURL KEV hash for default format
  # @param [Hash] marc_values
  # @return [Hash]
  def default_export_text(marc_values:)
    { 'rft.title' => marc_values[:title],
      'frt.creator' => marc_values[:author].first,
      'rft.aucorp' => marc_values[:corp_author].first,
      'rft.date' => marc_values[:publication_date],
      'rft.place' => marc_values[:publication_place].first,
      'rft.pub' => marc_values[:publisher_name].first,
      'rft.format' => marc_values[:format].first }
  end

  # Normalize format value
  # @param [Array<String>, String, nil] format
  # @return [String]
  def normalize_format(format)
    return '' if format.blank?

    single_format = format.first if format.is_a?(Array)
    single_format.downcase.strip
  end
end
