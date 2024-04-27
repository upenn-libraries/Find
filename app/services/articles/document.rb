# frozen_string_literal: true

# Namespace for classes that interact with the Summon API (Articles+)
module Articles
  # Represents a single document returned from the Summon service (Articles+)
  #
  # @see https://www.rubydoc.info/gems/summon/2.0.2/Summon/Document
  #   Document class documentation (Summon gem)
  # @see https://developers.exlibrisgroup.com/summon/apis/searchapi/response/documents
  #   documents field documentation (Summon API)
  class Document
    attr_reader :doc

    delegate :link, :publication_title, :content_type, to: :doc
    delegate :list, to: :authors, prefix: true

    # @param document [Summon::Document] the document object
    def initialize(document)
      @doc = document
    end

    # @return [String] the document title, including subtitle if present
    def title
      doc.subtitle.present? ? "#{doc.title}: #{doc.subtitle}" : doc.title
    end

    # @return [String] the document's full text online status
    def fulltext_online
      I18n.t('additional_results.summon.fields.fulltext') if doc.fulltext
    end

    # @return [Array<String>, nil] an array of the document's authors' full names in last, first format
    def authors
      return unless doc.authors.present?

      @authors ||= Articles::AuthorsList.new(doc.authors)
    end

    # @return [String, nil] the document's publication year if present
    def publication_year
      doc.publication_date&.year&.to_s
    end
  end
end
