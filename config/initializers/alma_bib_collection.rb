module AlmaGetBibCollections
  def get_collections(id, args = {})
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
