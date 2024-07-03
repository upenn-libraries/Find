# frozen_string_literal: true

#
# Concern centralizing methods that export citations from MARC record
module MARCExport
  extend ActiveSupport::Concern

  # Add extension for RIS
  # @param [MARC::Document] document
  def self.extended(document)
    document.will_export_as(:ris, 'application/x-research-info-systems')
  end

  # Export record to RIS format
  # @return [String]
  def export_as_ris
    ris_hash = to_ris_hash
    lines = ris_hash.keys
                    .select { |key| ris_hash[key].present? }
                    .flat_map { |key| render_ris_key_value(key, ris_hash[key]) }
    lines << 'ER  - '
    lines.compact.join("\n")
  end

  # Returns the MLA citation text of the current record
  # @return [String]
  def mla_citation_txt
    text = ''

    # Authors
    authors = marc(:creator_authors_list)
    text += format_authors(authors) if authors.present?

    # Title
    text += format_title

    # Edition
    text += format_edition

    # Publication
    publication = marc(:production_publication_citation_show).join
    text += publication.to_s if publication.present?

    text
  end

  # Returns the APA citation text of the current record
  # @return [String]
  def apa_citation_txt
    text = ''

    # Authors with first name initial
    text += format_apa_authors(marc(:creator_authors_list, first_initial_only: true))

    # Pub Date
    pub_year = marc(:date_publication)
    text += "(#{pub_year.year}). " if pub_year.present?

    # Title
    text += format_title

    # Edition
    text += format_edition

    # Publisher info
    text + format_publisher
  end

  # Returns the Chicago citation text of the given record
  # @return [String]
  def chicago_citation_txt
    text = ''

    # Authors
    authors = marc(:creator_authors_list)
    text += format_authors(authors, cite: :chicago) if authors.present?

    # Title
    text += format_title

    # Additional title
    contributors = marc(:creator_contributors_list)
    additional_title = format_additional_title(contributors['Translator'],
                                               contributors['Editor'],
                                               contributors['Compiler'])
    text += additional_title if additional_title.present?

    # Edition
    text += format_edition

    # Publication
    publication = marc(:production_publication_citation_show).join
    text += publication.to_s if publication.present?
    text
  end

  private

  # Format the author names text based on the total number of authors
  # Its used for both MLA and Chicago citation
  # @param [Array<string>] authors: array of the author names
  # @param [String] cite: either mla or chicago
  # @return [String]
  def format_authors(authors, cite: :mla)
    return '' if authors.blank?

    # MLA if more than four authors, use first and et al
    if authors.length >= 4 && cite == :mla
      first = authors.first
      return '' if first.blank?

      first.chop! if first.ends_with?(',')
      return "#{first}, et al. "
    end

    authors_list = []
    authors.each_with_index do |aut, idx|
      authors_list.push(format_author_text(aut, idx, authors.length))
      if cite == :chicago && authors.length >= 7 && idx >= 6
        authors_list.push(', et al.')
        break
      end
    end

    text = authors_list.join
    text += (text.last == '.' ? ' ' : '. ') if text.present?
    text
  end

  # Formats the text of an author based on its position within list
  # @param [String] aut: the author's name
  # @param [Int] idx: index of the author within the list
  def format_author_text(aut, idx, length)
    return '' if aut.blank?

    aut = aut.strip
    aut = aut.chop if aut.ends_with?(',')

    if idx.zero? # first
      aut
    elsif idx == length - 1 # last
      ", and #{convert_name_order(aut)}."
    else # all others
      ", #{convert_name_order(aut)}"
    end
  end

  # Formats the author list display for APA citation
  # @param [Array<String>] authors
  # @return [String]
  def format_apa_authors(authors)
    return '' if authors.blank?

    authors_list = []
    authors.each_with_index do |aut, idx|
      authors_list.push(format_apa_author_text(aut, idx, authors.length))
    end
    text = authors_list.join
    text + (text.last == '.' ? ' ' : '. ') if text.present?
  end

  # Formats one author in APA format based on its index within list
  # @param [String] aut: author's name
  # @param [Int] idx: index of this author within list
  def format_apa_author_text(aut, idx, length)
    aut = aut.strip
    aut = aut.chop if aut.ends_with?(',')

    if idx.zero? # first
      aut
    elsif idx == length - 1 # last
      ", &amp; #{aut}"
    else # all others
      ", #{aut}"
    end
  end

  # Formats the title display
  # @return [String]: the title string
  def format_title
    title = marc(:title_show)
    if title.present?
      title += title.ends_with?('.') ? ' ' : '. '
      "<i>#{title}</i>"
    else
      ''
    end
  end

  # Formats the edition display
  # @return [String]: the edition string
  def format_edition
    edition = marc(:edition_show, with_alternate: false).join
    if edition.present?
      edition + (edition.ends_with?('.') ? ' ' : '. ')
    else
      ''
    end
  end

  # Formats the publisher information
  # @return [String]: the publisher information
  def format_publisher
    publisher = marc(:production_publication_citation_show, with_year: false).join
    if publisher.present?
      # if ends with ',' or '.' remove it
      publisher.chop! if publisher.ends_with?(',', '.')
      "#{publisher}."
    else
      ''
    end
  end

  # Formats the additional title for Chicago citation
  # @param [Array<String>] translators
  # @param [Array<String>] editors
  # @param [Array<String>] compilers
  # @return [String]
  def format_additional_title(translators, editors, compilers)
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
    "#{role_text} by #{contributors.collect { |name| convert_name_order(name) }.join(' and ')}. " if role_text.present?
  end

  # Convert "Lastname, First" to "First Lastname"
  # @param [String] name value for processing
  # @return [String]
  def convert_name_order(name)
    return name unless name.include? ','

    parts = name.split(',')
    "#{parts[1].squish} #{parts[0].squish}"
  end

  def render_ris_key_value(key, val)
    if val.is_a?(Array)
      val.map { |v| "#{key}  - #{v}" }
    else
      "#{key}  - #{val}"
    end
  end

  def to_ris_hash
    h = {}
    self.class.ris_field_mappings.each do |key, val|
      h[key] = if val.is_a?(Proc)
                 instance_eval(&val)
               else
                 fetch(val, '')
               end
    end
    h
  end
end
