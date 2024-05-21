# frozen_string_literal: true

module Fulfillment
  class Endpoint
    class Illiad
      # This class accepts a hash of parameters that are sent to the ILL form and provides clear methods for retrieving
      # information about the request being made. The params are both OpenParams and custom parameters. This class is
      # used both when rendering the form and when submitting the request to Illiad.
      class Params
        attr_reader :open_params

        # TODO: we should memoize all of these methods

        def initialize(open_params)
          @open_params = open_params
        end

        # Skipping mapping the following values because it looks like they are unused in the form or submission request:
        #   - 'AN'
        #   - 'PY'
        #   - 'PB'
        #   - 'pid'
        #   - 'source'

        # TODO: this should be memoized

        # Request type. Used to be requesttype.
        def request_type
          if search('genre', 'rft.genre')&.downcase == 'unknown'
            'Book'
          else
            type = search('genre', 'Type', 'requesttype', 'rft.genre') || 'Article'
            type = 'Article' if type == 'issue'
            type = type.sub(/^(journal|bookitem|book|conference|article|preprint|proceeding).*?$/i, '\1')
            type = type.capitalize if ['article', 'book'].member?(type)
            type
          end
        end

        def author
          combined_name = if (aulast = search('rft.aulast', 'aulast'))
                            [aulast, search('rft.aufirst')].join(',')
                          end

          search('Author', 'author', 'aau', 'au', 'rft.au') || combined_name
        end

        # Chapter title. Used to be chaptitle.
        def chapter_title
          search('chaptitle')
        end

        # Book title. Used to be booktitle.
        def book_title
          search('title', 'Book', 'bookTitle', 'booktitle', 'rft.title')
        end

        def edition
          search('edition', 'rft.edition')
        end

        def publisher
          search('publisher', 'Publisher', 'rft.pub')
        end

        def place
          search('place', 'PubliPlace', 'rft.place')
        end

        def journal
          return open_params['bookTitle'] if open_params['bookTitle'].present? && request_type == 'bookitem'

          search('Journal', 'journal', 'rft.btitle', 'rft.jtitle', 'rft.title', 'title')
        end

        # Instead of using this method we should be able to use params.book_title || params.journal
        # def title
        #   book_title || journal
        # end

        def article
          search('Article', 'article', 'atitle', 'rft.atitle')
        end

        # Month of publication (usually used for Journals). Used when submitting Illiad request. Used to be pmonth.
        def month
          search('pmonth', 'rft.month') || ''
        end

        # TODO: maybe convert to `date`
        def rftdate
          search('rftdate', 'rft.date')
        end

        def year
          # Relais/BD sends dates through as rft.date but it may be a book request
          if borrow_direct? && request_type == 'Book'
            open_params['date'].presence || rftdate
          else
            search('Year', 'year', 'rft.year', 'rft.pubyear', 'rft.pubdate')
          end
        end

        def volume
          search('Volume', 'volume', 'rft.volume')
        end

        def issue
          search('Issue', 'issue', 'rft.issue')
        end

        def issn
          search('issn', 'ISSN', 'rft.issn')
        end

        def isbn
          search('isbn', 'ISBN', 'rft.isbn')
        end

        # Citation source.
        #
        # This field was in our previous form but was removed in this iteration. This value is
        # used when submitting an Illiad request.
        def sid
          search('sid', 'rfr_id')
        end

        def comments
          search('UserId', 'comments')
        end

        # Bib id for record in Alma. Used when submitting Illiad request.
        def bibid
          search('record_id', 'id', 'bibid')
        end

        def pages
          spage = search('Spage', 'spage', 'rft.spage')
          epage = search('Epage', 'epage', 'rft.epage')

          if open_params['Pages'].present? && spage.empty?
            spage, epage = open_params['Pages'].split(/-/)
          end

          pages = open_params['pages'].presence
          pages = [spage, epage].join('-') if pages.blank?
          pages = 'none specified' if pages.empty?

          pages
        end

        # Pubmed identifier. Used when submitting Illiad request.
        def pmid
          return nil unless open_params['rft_id'].present? && open_paramsp['rft_id'].starts_with?('pmid')

          open_params['rft_id'].split(':')[1]
        end

        # Return true if this is a BorrowDirect request.
        def borrow_direct?
          sid == 'BD' || open_params['bd'] == 'true'
        end

        # Request to checkout a book or other physical item.
        def loan?
          return false if open_params.blank?

          request_type == 'Book'
        end

        # Request to scan an article or chapter.
        def scan?
          return false if open_params.blank?

          request_type == 'Article'
        end

        # Sequentially looks up each key provided and returns the first value that returns true to `present?`.
        # Returns nil if none of the keys returned a non-blank value.
        def search(*keys)
          selected_key = keys.find do |key|
            open_params[key].present?
          end

          selected_key ? open_params[selected_key] : nil
        end
      end
    end
  end
end
