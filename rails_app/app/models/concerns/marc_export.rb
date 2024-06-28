# frozen_string_literal: true

#
# Concern centralizing methods that export citations from MARC record
module MARCExport
  extend ActiveSupport::Concern

  def self.extended(document)
    document.will_export_as(:ris, 'application/x-research-info-systems')
  end

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
    title = marc(:title_show)
    if title.present?
      title += title.ends_with?('.') ? ' ' : '. '
      text += "<i>#{title}</i>"
    end

    # Edition
    edition = marc(:edition_show, with_alternate: false).join
    if edition.present?
      edition += edition.ends_with?('.') ? ' ' : '. '
      text += edition.to_s
    end

    # Publication
    publication = marc(:production_publication_citation_show).join
    text += publication.to_s if publication.present?

    text
  end

  # Returns the APA citation text of the current record
  # @return [String]
  def apa_citation_txt
    text = ''
    authors_list_final = []

    # Authors with first name initial
    authors = marc(:creator_authors_list, first_initial_only: true)
    authors.each_with_index do |aut, idx|
      aut = aut.strip
      aut = aut.chop if aut.ends_with?(',')

      author_text = if idx.zero? # first
                      aut
                    elsif idx == authors.length - 1 # last
                      ", &amp; #{aut}"
                    else # all others
                      ", #{aut}"
                    end
      authors_list_final.push(author_text)
    end
    text += authors_list_final.join
    if text.present?
      text += text.last == '.' ? ' ' : '. '
    end

    # Pub Date
    pub_year = marc(:date_publication).year
    text += "(#{pub_year}). " if pub_year.present?

    # Title
    title = marc(:title_show)
    if title.present?
      title += title.ends_with?('.') ? ' ' : '. '
      text += "<i>#{title}</i>"
    end

    # Edition
    edition = marc(:edition_show, with_alternate: false).join
    if edition.present?
      edition += edition.ends_with?('.') ? ' ' : '. '
      text += edition.to_s
    end

    # Publisher info
    publisher = marc(:production_publication_citation_show, with_year: false).join
    if publisher.present?
      # if ends with ',' or '.' remove it
      publisher.chop! if publisher.ends_with?(',', '.')
      text += "#{publisher}."
    end

    text
  end

  # Returns the Chicago citation text of the given record
  # @return [String]
  def chicago_citation_txt
    text = ''

    contributors = marc(:creator_contributors_list, include_authors: true)

    authors = contributors['Author']
    translators = contributors['Translator']
    editors = contributors['Editor']
    compilers = contributors['Compiler']

    text += format_authors(authors) if authors.present?

    # Title
    title = marc(:title_show)
    if title.present?
      title += title.ends_with?('.') ? ' ' : '. '
      text += "<i>#{title}</i>"
    end

    additional_title = ''
    if translators.present?
      additional_title += "Translated by #{translators.collect { |name|
        convert_name_order(name)
      }.join(' and ')}. "
    end
    if editors.present?
      additional_title += "Edited by #{editors.collect { |name|
        convert_name_order(name)
      }.join(' and ')}. "
    end
    if compilers.present?
      additional_title += "Compiled by #{compilers.collect { |name|
        convert_name_order(name)
      }.join(' and ')}. "
    end

    text += additional_title if additional_title.present?

    # Edition
    edition = marc(:edition_show, with_alternate: false).join
    if edition.present?
      edition += edition.ends_with?('.') ? ' ' : '. '
      text += edition.to_s
    end

    # Publication
    publication = marc(:production_publication_citation_show).join
    text += publication.to_s if publication.present?

    text
  end

  private

  # Format the author names text based on the total number of authors
  # @param [Array<string>] authors: array of the author names
  # @return [String]
  def format_authors(authors)
    return '' if authors.blank?

    authors_final = []

    if authors.length >= 4
      text = "#{authors.first}, et al. "
    else
      authors.each_with_index do |aut, idx|
        aut = aut.strip
        aut = aut.chop if aut.ends_with?(',')

        author_text = if idx.zero? # first
                        aut
                      elsif idx == authors.length - 1 # last
                        ", and #{convert_name_order(aut)}."
                      else # all others
                        ", #{convert_name_order(aut)}"
                      end
        authors_final.push(author_text)
      end
      text = authors_final.join
    end

    if text.present?
      text += text.last == '.' ? ' ' : '. '
    end

    text
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
