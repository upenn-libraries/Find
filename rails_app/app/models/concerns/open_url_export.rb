# frozen_string_literal: true

# Methods that export OpenURL CTX KEV from MARC record
# In Franklin, this logic is included with the `blacklight-marc` gem,
# but we have extracted it into a concern to make it easier to maintain.
module OpenUrlExport
  extend ActiveSupport::Concern

  # Export the current record as an OpenURL query string
  # @param [Array<String>, String, nil] format
  # @return [String]
  def export_as_openurl_ctx_kev(format = nil)
    values = marc_values(format)

    case normalize_format(format)
    when 'book'
      book_export_kev(values).to_openurl
    when /journal/i
      journal_export_kev(values).to_openurl
    else
      default_export_kev(values).to_openurl
    end
  end

  private

  # Extract values from MARC record using PennMARC parser
  # @param [Array<String>, String] format
  # @return [Hash]
  def marc_values(format)
    { title: marc(:title_show),
      author: marc(:creator_authors_list, main_tags_only: true),
      corp_author: marc(:creator_corporate_search),
      publication_date: marc(:date_publication).year,
      publication_place: marc(:production_publication_ris_place_of_pub),
      publisher_name: marc(:production_publication_ris_publisher),
      publisher_info: marc(:production_publication_citation_show),
      edition: marc(:edition_show, with_alternate: false),
      isbn: marc(:identifier_isbn_show), issn: marc(:identifier_issn_show),
      format: normalize_format(format) }
  end

  # Assemble OpenURL KEV hash for book format
  # @param [Hash] marc_values
  # @return [Hash]
  def book_export_kev(marc_values)
    { 'ctx_ver' => 'Z39.88-2004', 'rft_val_fmt' => 'info:ofi/fmt:kev:mtx:book',
      'rfr_id' => 'info:sid/find.library.upenn.edu:generator',
      'rft.btitle' => marc_values[:title], 'rft.title' => marc_values[:title],
      'rft.au' => marc_values[:author], 'rft.aucorp' => marc_values[:corp_author],
      'rft.date' => marc_values[:publication_date],
      'rft.place' => marc_values[:publication_place],
      'rft.pub' => marc_values[:publisher_name],
      'rft.edition' => marc_values[:edition],
      'rft.isbn' => marc_values[:isbn] }
  end

  # Assemble OpenURL KEV hash for journal format
  # @param [Hash] marc_values
  # @return [Hash]
  def journal_export_kev(marc_values)
    { 'ctx_ver' => 'Z39.88-2004', 'rft_val_fmt' => 'info:ofi/fmt:kev:mtx:journal',
      'rfr_id' => 'info:sid/find.library.upenn.edu:generator',
      'rft.title' => marc_values[:title], 'rft.atitle' => marc_values[:title],
      'rft.aucorp' => marc_values[:corp_author],
      'rft.date' => marc_values[:publication_date],
      'rft.issn' => marc_values[:issn] }
  end

  # Assemble OpenURL KEV hash for default format
  # @param [Hash] marc_values
  # @return [Hash]
  def default_export_kev(marc_values)
    { 'ctx_ver' => 'Z39.88-2004', 'rft_val_fmt' => 'info:ofi/fmt:kev:mtx:dc',
      'rfr_id' => 'info:sid/find.library.upenn.edu:generator',
      'rft.title' => marc_values[:title],
      'rft.creator' => marc_values[:author],
      'rft.aucorp' => marc_values[:corp_author],
      'rft.date' => marc_values[:publication_date],
      'rft.place' => marc_values[:publication_place],
      'rft.pub' => marc_values[:publisher_name],
      'rft.format' => marc_values[:format] }
  end

  # Normalize format value
  # @param [Array<String>, String, nil] format
  # @return [String]
  def normalize_format(format)
    return '' if format.blank?

    single_format = format.is_a?(Array) ? format.first : format
    single_format.downcase.strip
  end
end
