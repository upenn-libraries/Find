# frozen_string_literal: true

module Illiad
  # An Enumerable to use when retrieving multiple Illiad requests
  class RequestSet
    include Enumerable

    attr_reader :requests

    # @param requests [Array]
    def initialize(requests:)
      @requests = requests.map { |req| Illiad::Request.new(**req) }
    end

    def each(&)
      requests.each(&)
    end
  end
end
