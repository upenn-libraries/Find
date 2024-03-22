# frozen_string_literal: true

module Illiad
  # An Enumerable to use when retrieving multiple Illiad requests
  class RequestSet
    include Enumerable

    attr_reader :requests

    # @param requests [Array]
    def initialize(requests:)
      @requests = requests
    end

    def each(&)
      requests.map { |req| Illiad::Request.new(data: req) }.each(&)
    end
  end
end