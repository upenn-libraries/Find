# frozen_string_literal: true

# rubocop:disable Style/RedundantSelf, Style/HashSyntax, Style/GuardClause, Metrics/MethodLength
module AlmaExtensions
  # Additions for the Alma::Bib class that:
  #   - expose the "Get E-Collection for a Bib" API endpoint
  module Bib
    # Exposing the "Get E-Collection for a Bib" API endpoint. This allows us to get a top-level
    # view of any e-collections associated with a Bib.
    #
    # We need this in order to grab any Inventory that is represented in Alma as an E-Collection
    # without an associated portfolio.
    #
    # API Documentation: https://developers.exlibrisgroup.com/alma/apis/docs/bibs/R0VUIC9hbG1hd3MvdjEvYmlicy97bW1zX2lkfS9lLWNvbGxlY3Rpb25z/
    #
    # @param id [String]
    # @return [Array]
    def get_ecollections(id, args = {})
      response = HTTParty.get(
        "#{self.bibs_base_path}/#{id}/e-collections",
        query: { mms_id: id }.merge(args),
        headers:,
        timeout:
      )

      if response.code == 200
        get_body_from(response)
      else
        raise StandardError, get_body_from(response)
      end
    end
  end
end
# rubocop:enable Style/RedundantSelf, Style/HashSyntax, Style/GuardClause, Metrics/MethodLength

Alma::Bib.extend(AlmaExtensions::Bib)
