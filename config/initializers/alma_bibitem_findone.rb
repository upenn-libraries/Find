# frozen_string_literal: true

# The Alma API gem does not yet support the ability to get a single item from a bib holding, using the
# mms_id, holding_id, and item_pid. This class is a workaround for that limitation.

# This functionality has been merged to main in the Alma gem, but a new version has not been released.
module AlmaBibItemFindOne
  def find_one(mms_id:, holding_id:, item_pid:, options: {})
    url = "#{bibs_base_path}/#{mms_id}/holdings/#{holding_id}/items/#{item_pid}"
    response = HTTParty.get(url, headers:, query: options, timeout:)
    new(response)
  end
end

Alma::BibItem.extend(AlmaBibItemFindOne)