# frozen_string_literal: true

module AdditionalResults
  module Sources
    # Renders additional search results from the Summon API (Articles+)
    class SummonComponent < ViewComponent::Base
      include AdditionalResults::SourceHelper

      delegate :documents, to: :search

      attr_reader :search, :facet_counts

      # @param query [String] the search term
      def initialize(query:, **options)
        @query = query
        @classes = Array.wrap(options[:class])&.join(' ')
        @search = Articles::Search.new(query_term: query)
        @facet_counts = @search.facet_manager&.counts || nil
      end

      # @return [String] the URL linking to the results of the search on Articles+
      def summon_url
        Articles::Search.summon_url(query: @search.query_string)
      end

      # Generates a comma-delimited overall record count for the search results
      #
      # @return [Integer] the number of documents matching the search query
      def record_count
        # @todo Figure out why this count never matches the count on Articles+
        number_with_delimiter(search.record_count)
      end

      # Generates a formatted string containing the authors, publication title, and
      # publication year of a document
      #
      # @param doc [Articles::Document] the document object
      # @return [String] a comma-separated string containing the document's authors,
      #   publication title, and publication year
      def info_display(doc)
        info = [doc.authors&.list, publication_title_display(doc), doc.publication_year]
        info.compact.join(', ')
      end

      # Generates the display for the availability of a document
      #
      # @param doc [Document] the document object
      # @return [String] the HTML for a badge displaying the document's
      #   content type and fulltext availability
      def availability_display(doc)
        badge_type = doc.fulltext_online.present? ? 'bg-success' : 'bg-secondary'

        content_tag(:span, class: "badge #{badge_type}") do
          if doc.fulltext_online.present?
            [doc.content_type, doc.fulltext_online].compact.join(': ')
          else
            doc.content_type
          end
        end
      end

      # If there's only one facet count for a facet type, we probably don't need to display it
      #
      # @param facet_display_name [String] the display name for the facet (ex: 'ContentType')
      # @return [Boolean] true if there is more than one facet count
      def render_facet_counts?(facet_display_name)
        num_counts = facet_counts[facet_display_name].present? ? facet_counts[facet_display_name].count : 0
        num_counts > 1
      end

      # Generates a link for a facet count that displays its label and
      # document count and links out to the facet-filtered results on Articles+
      #
      # @see Articles::FacetManager#map_facet_counts
      #
      # @param facet_count [Hash] a hash containing data for the facet count
      # @return [String] the HTML code for the facet count link
      def facet_count_link(facet_count)
        doc_count = number_with_delimiter(facet_count[:doc_count])

        content_tag(:li, class: 'list-inline-item') do
          link_to(facet_count[:url], target: '_blank', rel: 'noopener') do
            "#{facet_count[:label]} (#{doc_count})"
          end
        end
      end

      private

      # Italicizes the document's publication title if it exists
      #
      # @param doc [Articles::Document] the document object
      def publication_title_display(doc)
        content_tag('em', doc.publication_title) if doc.publication_title
      end
    end
  end
end
