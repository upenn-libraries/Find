# frozen_string_literal: true

module Illiad
  class Request
    # Interface to access Illiad item metadata
    class ItemData
      def initialize(data)
        @data = data
      end

      # @return [String, nil]
      def title
        @data[:LoanTitle] || @data[:PhotoJournalTitle]
      end

      # @return [String, nil]
      def section_title
        @data[:PhotoArticleTitle]
      end

      # @return [String, nil]
      def author
        @data[:LoanAuthor] || @data[:PhotoArticleAuthor]
      end

      # @return [String, nil]
      def publication_date
        @data[:LoanDate] || @data[:PhotoJournalYear]
      end

      # @return [String, nil]
      def volume
        @data[:PhotoJournalVolume]
      end

      # @return [String, nil]
      def issue
        @data[:PhotoJournalIssue]
      end

      # @return [String, nil]
      def pages
        @data[:PhotoJournalInclusivePages]
      end

      # @return [String, nil]
      def issn
        @data[:ISSN]
      end

      # @return [String, nil]
      def citation_source
        @data[:CitedIn]
      end
    end
  end
end
