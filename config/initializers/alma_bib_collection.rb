# frozen_string_literal: true

# The Alma API gem does not appear to expose the "Get E-Collection for a Bib" API endpoint. We need this in order to
# grab any Inventory that is represented in Alma as an E-Collection without an associated portfolio.
#
# API Documentation: https://developers.exlibrisgroup.com/alma/apis/docs/bibs/R0VUIC9hbG1hd3MvdjEvYmlicy97bW1zX2lkfS9lLWNvbGxlY3Rpb25z/
#
# This initializer adds a class method get_ecollections to the Alma::Bib class used as the means for getting a top-level
# view of any e-collections associated with a Bib.
#
# I wrote this in such a way that it could be offered as an MR to the Alma gem, eventually.
#
# rubocop:disable Style, Metrics
module AlmaGetBibCollections
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

Alma::Bib.extend(AlmaGetBibCollections)
# rubocop:enable Style, Metrics
