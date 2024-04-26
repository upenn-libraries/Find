# frozen_string_literal: true

# The Alma API gem does not yet support the ability to get all holdings for a bib using the mms_id and the holding_id.
# This class is a workaround for that limitation.
module AlmaBibHoldingFindAll
  def find_all(mms_id:, options: {})
    url = "#{bibs_base_path}/#{mms_id}/holdings"
    response = HTTParty.get(url, headers: headers, query: options, timeout: timeout)
    JSON.parse(response.body)
  end
end

Alma::BibHolding.extend(AlmaBibHoldingFindAll)
