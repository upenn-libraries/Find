# frozen_string_literal: true

module AlmaApi
  class Holdings

    def self.find(mms_id)
      availability_data = Alma::Bib.get_availability([mms_id])
      holdings(mms_id, holding_data(mms_id, availability_data))
    end

    def self.find_many; end

    # status: holdings/availability(get_availability), base_status(BibItem)
    # policy : item_data (BibItem)
    # description: holding_data (BibItem) -Depends on kind of item
    # format: inventory_type (get_availability)
    # count: total_items in Holdings (get_availability)
    # location: Holdings/Library (physical) Holdings/collection (electronic) (get availability)
    # id: holding_id from Holdings / portfolio_id (elec) (get availability)
    # href: punt
    #
    # total: count holdings array (get availability)

    private

    def holding_data(mms_id, availability_data)
      availability_data.availability.dig(mms_id, :holdings)
    end

    def holdings(mms_id, holding_data)
      holding_data.map do |holding|
        format_holding(mms_id, holding)
      end
    end

    def format_holding(mms_id, holding)
      {
        # for online records - activation_status? or just 'online access'?
        status: holding.fetch('availability', ''),
        policy: '',
        description: holding['holding_info'] || holding['call_number'],
        format: holding.fetch('inventory_type', ''),
        count: holding.fetch('total_items', ''),
        location: holding.fetch('location', ''),
        id: holding['holding_id'] || holding['portfolio_id'],
        href: "/catalog/#{mms_id}##{holding['holding_id']}"
      }
    end
  end
end
