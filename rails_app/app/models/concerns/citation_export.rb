# frozen_string_literal: true

#
# Concern centralizing methods that export citations from MARC record
module CitationExport
  extend ActiveSupport::Concern

  # Returns the MLA citation text of the current record
  # @return [String]
  def export_as_mla_citation_txt
    authors = format_authors(marc(:creator_authors_list), :mla)
    title = format_title
    edition = format_edition
    publication = marc(:production_publication_citation_show).join

    [authors, title, edition, publication].join
  end

  # Returns the APA citation text of the current record
  # @return [String]
  def export_as_apa_citation_txt
    # Authors with first name initial
    authors = format_authors(marc(:creator_authors_list, first_initial_only: true), :apa)

    pub_year = marc(:date_publication)
    year = "(#{pub_year.year}). " if pub_year.present?

    title = format_title
    edition = format_edition
    publisher = format_apa_publisher

    [authors, year, title, edition, publisher].join
  end

  # Returns the Chicago citation text of the given record
  # @return [String]
  def export_as_chicago_citation_txt
    authors = format_authors(marc(:creator_authors_list), :chicago)
    title = format_title

    # Additional title
    contributors = marc(:creator_contributors_list)
    additional_title = format_chicago_additional_title(contributors['Translator'],
                                                       contributors['Editor'],
                                                       contributors['Compiler'])
    edition = format_edition
    publication = marc(:production_publication_citation_show).join

    [authors, title, additional_title, edition, publication].join
  end

  private

  # Adds the final period to the given text
  # @param [String] text
  # @return [String]
  def add_final_period(text)
    return if text.blank?

    text + (text.last == '.' ? ' ' : '. ')
  end

  # Format the author names text based on the total number of authors
  # Its used for both MLA and Chicago citation
  # @param [Array<string>] authors: array of the author names
  # @param [String] cite: mla, apa or chicago
  # @return [String]
  def format_authors(authors, cite)
    return '' if authors.blank?

    # MLA if more than four authors, use first and et al
    if authors.length >= 4 && cite == :mla
      first = authors.first
      first.chop! if first.last == ','
      return "#{first}, et al. "
    end

    authors_list = cite == :chicago ? authors.first(7) : authors
    # Strip author name if it ends with comma
    authors_formatted = authors_list.map { |aut| aut.last == ',' ? aut.chop : aut }
    # Convert name order to First Last for MLA and Chicago for the authors after first one
    unless cite == :apa
      authors_formatted = authors_formatted.map.with_index { |aut, idx| idx.positive? ? convert_name_order(aut) : aut }
    end

    word_connector = cite == :apa ? ' &amp; ' : ' and '
    text = authors_formatted.to_sentence(two_words_connector: word_connector, last_word_connector: word_connector)

    text += ', et al' if cite == :chicago && authors.count > 7
    add_final_period(text)
  end

  # Formats the title display
  # @return [String]: the title string
  def format_title
    title = marc(:title_show)
    return if title.blank?

    "<i>#{add_final_period(title)}</i>"
  end

  # Formats the edition display
  # @return [String]: the edition string
  def format_edition
    edition = marc(:edition_show, with_alternate: false).join
    return if edition.blank?

    add_final_period(edition)
  end

  # Formats the publisher information
  # @return [String]: the publisher information
  def format_apa_publisher
    publisher = marc(:production_publication_citation_show, with_year: false).join
    return if publisher.blank?

    # if ends with ',' or '.' remove it
    publisher.chop! if publisher.ends_with?(',', '.')
    "#{publisher}."
  end

  # Formats the additional title for Chicago citation
  # @param [Array<String>] translators
  # @param [Array<String>] editors
  # @param [Array<String>] compilers
  # @return [String]
  def format_chicago_additional_title(translators, editors, compilers)
    additional_title = ''
    additional_title += format_contributors(translators, 'Translated') if translators.present?
    additional_title += format_contributors(editors, 'Edited') if editors.present?
    additional_title += format_contributors(compilers, 'Compiled') if compilers.present?
    additional_title
  end

  # Formats the title text of the list of contributors - used by method format_additional_title
  # @param [Array<String>] contributors
  # @param [String] role_text
  # @return [String]
  def format_contributors(contributors, role_text)
    return if contributors.blank? || role_text.blank?

    "#{role_text} by #{contributors.collect { |name| convert_name_order(name) }.join(' and ')}. "
  end

  # Convert "Lastname, First" to "First Lastname"
  # @param [String] name value for processing
  # @return [String]
  def convert_name_order(name)
    return name unless name.include? ','

    parts = name.split(',')
    "#{parts[1].squish if parts[1].present?} #{parts[0].squish if parts[0].present?}"
  end
end
