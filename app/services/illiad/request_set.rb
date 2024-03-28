# frozen_string_literal: true

module Illiad
  # An Enumerable to use when retrieving multiple Illiad requests
  class RequestSet
    include Enumerable

    attr_reader :requests

    # @param requests [Array]
    def initialize(requests:)
      @requests = requests.map { |req| Illiad::Request.new(data: req) }
    end

    def each(&)
      requests.each(&)
    end

    # @return [Array<Illiad::Request>]
    def loans
      @loans ||= select(&:loan?)
    end

    # @return [Array<Illiad::Request>]
    def books_by_mail
      @books_by_mail ||= select(&:books_by_mail?)
    end

    # @return [Array<Illiad::Request>]
    def scans
      @scans ||= select(&:scan?)
    end
  end
end
