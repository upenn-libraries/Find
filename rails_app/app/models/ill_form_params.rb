# frozen_string_literal: true

class IllFormParams
  attr_reader :open_params

  def initialize(open_params)
    @open_params = open_params
  end

  # Skipping mapping the following values because it looks like they are unused in the form or submission request:
  #   - 'AN'
  #   - 'PY'
  #   - 'PB'
  #   - 'pid'
  #   - 'source'

  # Questions:
  #  - Is extracting the pmid still needed?

  def request_type # used to be requesttype
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

  def chaptitle
    search('chaptitle')
  end

  def booktitle
    search('title', 'Book', 'bookTitle', 'booktitle', 'rft.title') || ''
  end

  def edition
    search('edition', 'rft.edition') || ''
  end

  def publisher
    search('publisher', 'Publisher', 'rft.pub') || ''
  end

  def place
    search('place', 'PubliPlace', 'rft.place') || ''
  end

  def journal
    search('Journal', 'journal', 'rft.btitle', 'rft.jtitle', 'rft.title', 'title') || ''
  end

  def article
    search('Article', 'article', 'atitle', 'rft.atitle') || ''
  end

  def pmonth # only used when form is submitted
    search('pmonth', 'rft.month') || ''
  end

  def rftdate # TODO: maybe convert to `date`
    search('rftdate', 'rft.date')
  end

  def year
    search('Year', 'year', 'rft.year', 'rft.pubyear', 'rft.pubdate')
  end

  def volume
    search('Volume', 'volume', 'rft.volume') || ''
  end

  def issue
    search('Issue', 'issue', 'rft.issue') || ''
  end

  def issn
    search('issn', 'ISSN', 'rft.issn') || ''
  end

  def isbn
    search('isbn', 'ISBN', 'rft.isbn') || ''
  end

  def sid # Field was removed from form, should be sent in form submission
    search('sid', 'rfr_id') || ''
  end

  def comments
    search('UserId', 'comments') || ''
  end

  def bibid
    search('record_id', 'id', 'bibid') || ''
  end

  def pages
    spage = search('Spage', 'spage', 'rft.spage')
    epage = search('Epage', 'epage', 'rft.epage')

    if open_params['Pages'].present? && spage.empty?
      spage, epage = open_params['Pages'].split(/-/);
    end

    pages = open_params['pages'].presence
    pages = [spage, epage].join('-') if pages.blank?
    pages = 'none specified' if pages.empty?

    pages
  end

  def loan?
    return false if open_params.blank?

    request_type == 'Book'
  end

  # Request to scan of an article or chapter.
  def scan?
    return false if open_params.blank?

    request_type == 'Article'
  end

  # Sequentially looks up each key provided and returns the first value that returns true to `present?`. Returns nil
  # if none of the keys returned a non-blank value.
  def search(*keys)
    selected_key = keys.find do |key|
      open_params[key].present?
    end

    selected_key ? open_params[selected_key] : nil
  end
end