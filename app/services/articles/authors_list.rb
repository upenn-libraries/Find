# frozen_string_literal: true

module Articles
  # Generates a comma-separated list of authors returned from the Summon service
  # (Articles+) with names in 'first last' format
  class AuthorsList
    attr_reader :list

    # @param authors [Array<Summon::Author>] an array of authors
    def initialize(authors)
      @authors = authors.collect(&:fullname)
      @list = build_list
    end

    private

    # @return [Array<String>] an array of authors in 'first last' format
    def first_last
      @authors.map do |author|
        author.split(', ').reverse.join(' ')
      end
    end

    # @return [String] a comma-separated list of authors, truncated to first
    #   three names and 'et al.' if necessary
    def build_list
      if @authors.length > 3
        first_last[0..1].push('et al.').join(', ')
      else
        first_last.to_sentence
      end
    end
  end
end
