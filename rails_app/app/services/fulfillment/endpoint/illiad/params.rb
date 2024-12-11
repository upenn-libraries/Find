# frozen_string_literal: true

module Fulfillment
  class Endpoint
    class Illiad
      # This class accepts a hash of parameters that are sent to the ILL form and provides clear methods for retrieving
      # information about the request being made. The params are both OpenParams and custom parameters. This class is
      # used both when rendering the form and when submitting the request to Illiad.
      class Params
        attr_reader :open_params

        # @param open_params [Hash]
        def initialize(open_params)
          @open_params = open_params.stringify_keys
        end

        # Request type. Used to be requesttype.
        # @return [String, nil]
        def request_type
          if search('genre', 'rft.genre')&.downcase == 'unknown'
            'book'
          else
            type = search('genre', 'Type', 'requesttype', 'rft.genre') || 'article'
            type = type.downcase
            type = 'article' if type == 'issue'
            type.sub(/^(journal|bookitem|book|conference|article|preprint|proceeding).*?$/i, '\1')
          end
        end

        # @return [String, nil]
        def author
          combined_name = if (aulast = search('rft.aulast', 'aulast'))
                            [aulast, search('rft.aufirst')].join(',')
                          end

          search('author', 'Author', 'aau', 'au', 'rft.au') || combined_name
        end

        # Chapter title. Used to be chaptitle.
        # @return [String, nil]
        def chapter_title
          search('chaptitle')
        end

        # Book title. Used to be booktitle.
        # @return [String, nil]
        def book_title
          search('title', 'Book', 'bookTitle', 'booktitle', 'rft.title')
        end

        # @return [String, nil]
        def edition
          search('edition', 'rft.edition')
        end

        # @return [String, nil]
        def publisher
          search('publisher', 'Publisher', 'rft.pub')
        end

        # @return [String, nil]
        def place
          search('place', 'PubliPlace', 'rft.place')
        end

        # @return [String, nil]
        def journal
          return open_params['bookTitle'] if open_params['bookTitle'].present? && request_type == 'bookitem'

          search('journal', 'Journal', 'rft.btitle', 'rft.jtitle', 'rft.title', 'title')
        end

        # @return [String, nil]
        def title
          journal || book_title
        end

        # @return [String, nil]
        def article
          search('article', 'Article', 'atitle', 'rft.atitle')
        end

        # Month of publication (usually used for Journals). Used when submitting Illiad request. Used to be pmonth.
        # @return [String, nil]
        def month
          search('pmonth', 'rft.month')
        end

        # @return [String, nil]
        def date
          search('date', 'rftdate', 'rft.date')
        end

        # @return [String, nil]
        def year
          # Relais/BD sends dates through as rft.date but it may be a book request
          if borrow_direct? && request_type == 'book'
            date
          else
            search('year', 'Year', 'rft.year', 'rft.pubyear', 'rft.pubdate')
          end
        end

        # @return [String, nil]
        def volume
          search('volume', 'Volume', 'rft.volume')
        end

        # @return [String, nil]
        def issue
          search('issue', 'Issue', 'rft.issue')
        end

        # @return [String, nil]
        def issn
          search('issn', 'ISSN', 'rft.issn')
        end

        # @return [String, nil]
        def isbn
          search('isbn', 'ISBN', 'rft.isbn')
        end

        # Citation source.
        #
        # This value is used when submitting an Illiad request. 'sid' and 'rfr_id' are probably set by external sites
        # that route to our requesting endpoint. 'source' is used to help track the origin of our requests.
        # @return [String, nil]
        def sid
          search('sid', 'rfr_id', 'source')
        end

        # @return [String, nil]
        def comments
          search('comments', 'UserId')
        end

        # MMS id for record in Alma. Used when submitting Illiad request.
        # @return [String, nil]
        def mms_id
          search('mms_id', 'record_id', 'id', 'bibid')
        end

        # @return [String (frozen)]
        def pages
          spage = search('Spage', 'spage', 'rft.spage')
          epage = search('Epage', 'epage', 'rft.epage')

          pages = open_params['pages'].presence
          pages = "#{spage}-#{epage}" if pages.blank? && (spage || epage)
          pages = open_params['Pages'].presence if pages.blank?
          pages = 'none specified' if pages.blank?

          pages
        end

        # Pubmed identifier. Used when submitting Illiad request.
        # @return [String, nil]
        def pmid
          return nil unless open_params['rft_id'].present? && open_params['rft_id'].starts_with?('pmid')

          open_params['rft_id'].split(':')[1]
        end

        # Call number for item in our collection.
        def call_number
          search('call_number')
        end

        # Location where item is held. This only items to items in our collection.
        # @return [String, nil]
        def location
          search('location')
        end

        # Barcode for item in our collection.
        # @return [String, nil]
        def barcode
          search('barcode')
        end

        # Return true if this is a BorrowDirect request.
        # @return [Boolean]
        def borrow_direct?
          sid == 'BD' || open_params['bd'] == 'true'
        end

        # Returns true if the item being requested is a known boundwith.
        def boundwith?
          open_params['boundwith'] == 'true'
        end

        # Request to checkout a book or other physical item.
        # @return [Boolean]
        def loan?
          return false if open_params.blank?

          request_type == 'book'
        end

        # Request to scan an article or chapter. This handles all non-book cases.
        # @return [Boolean]
        def scan?
          return false if open_params.blank?

          !loan?
        end

        # Sequentially looks up each key provided and returns the first value that returns true to `present?`.
        # Returns nil if none of the keys returned a non-blank value.
        # @param keys [Array]
        # @return [String, nil]
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
