# frozen_string_literal: true

# Methods that export OpenURL CTX KEV from MARC record
# In Franklin, this logic is included with the `blacklight-marc` gem,
# but we have extracted it into a concern to make it easier to maintain.
module OpenUrlExport
  extend ActiveSupport::Concern

  CTX_VER = 'Z39.88-2004'
  RFR_ID = 'info:sid/find.library.upenn.edu:generator'

  # Export the current record as an OpenURL query string
  # @param [Array<String>, String, nil] format
  # @return [String]
  def export_as_openurl_ctx_kev(format = nil)
    normalized_format = normalize_format(format)
    values = marc_values(normalized_format)

    case normalized_format
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
      publication_date: marc(:date_publication)&.year,
      publication_place: marc(:production_publication_ris_place_of_pub),
      publisher_name: marc(:production_publication_ris_publisher),
      publisher_info: marc(:production_publication_citation_show),
      edition: marc(:edition_show, with_alternate: false),
      isbn: marc(:identifier_isbn_show), issn: marc(:identifier_issn_show),
      format: format }
  end

  # Shared attributes for OpenURL KEV hash
  # @return [Hash]
  def shared_attributes
    { 'ctx_ver' => CTX_VER,
      'rfr_id' => RFR_ID }
  end

  # Assemble OpenURL KEV hash for book format
  # @param [Hash] marc_values
  # @return [Hash]
  def book_export_kev(marc_values)
    shared_attributes.merge({ 'rft_val_fmt' => 'info:ofi/fmt:kev:mtx:book',
                              'rft.btitle' => marc_values[:title],
                              'rft.title' => marc_values[:title],
                              'rft.au' => marc_values[:author],
                              'rft.aucorp' => marc_values[:corp_author],
                              'rft.date' => marc_values[:publication_date],
                              'rft.place' => marc_values[:publication_place],
                              'rft.pub' => marc_values[:publisher_name],
                              'rft.edition' => marc_values[:edition],
                              'rft.isbn' => marc_values[:isbn] })
  end

  # Assemble OpenURL KEV hash for journal format
  # @param [Hash] marc_values
  # @return [Hash]
  def journal_export_kev(marc_values)
    shared_attributes.merge({ 'rft_val_fmt' => 'info:ofi/fmt:kev:mtx:journal',
                              'rft.title' => marc_values[:title],
                              'rft.atitle' => marc_values[:title],
                              'rft.aucorp' => marc_values[:corp_author],
                              'rft.date' => marc_values[:publication_date],
                              'rft.issn' => marc_values[:issn] })
  end

  # Assemble OpenURL KEV hash for default format
  # @param [Hash] marc_values
  # @return [Hash]
  def default_export_kev(marc_values)
    shared_attributes.merge({ 'rft_val_fmt' => 'info:ofi/fmt:kev:mtx:dc',
                              'rft.title' => marc_values[:title],
                              'rft.creator' => marc_values[:author],
                              'rft.aucorp' => marc_values[:corp_author],
                              'rft.date' => marc_values[:publication_date],
                              'rft.place' => marc_values[:publication_place],
                              'rft.pub' => marc_values[:publisher_name],
                              'rft.format' => marc_values[:format] })
  end

  # Normalize format value
  # @param [Array<String>, String, nil] format
  # @return [String]
  def normalize_format(format)
    return '' if format.blank?

    Array.wrap(format).first.downcase.strip
  end
end
