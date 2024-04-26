# frozen_string_literal: true

# TODO: figure out a less stupid name
module Items
  # service for various item methods
  class Service
    FACULTY_EXPRESS_CODE = 'FacEXP'
    COURTESY_BORROWER_CODE = 'courtesy'

    class BoundwithError < StandardError; end

    # @return [PennItem]
    def self.item_for(mms_id:, holding_id:, item_pid:)
      raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id && item_pid
      item = Alma::BibItem.find_one(mms_id: mms_id, holding_id: holding_id, item_pid: item_pid).item
      PennItem.new(item)
    end

    # Return an array of PennItems for a given mms_id and holding_id, fake an item if a holding has no items
    # @return [Array<PennItem>]
    def self.items_for(mms_id:, holding_id:)
      raise ArgumentError, 'Insufficient identifiers set' unless mms_id && holding_id

      item_set = Alma::BibItem.find(mms_id, holding_id: holding_id).items
      return item_set if item_set.present?

      holdings = Alma::BibHolding.find_all(mms_id: mms_id)

      # TODO: implement boundwith support, see example mms_id: 9920306003503681
      raise BoundwithError if holdings['holding'].blank?

      # Fake an item when a holding has no items, ugh
      [PennItem.new({
                      'bib_data' => holdings['bib_data'],
                      'holding_data' => holdings['holding']
                                          &.find { |holding| holding['holding_id'] == holding_id },
                      'item_data' => {}
                    })]
    end

    # @return [Array]
    def self.options_for(item:, ils_group:)
      return [:aeon] if item.aeon_requestable?
      return [:archives] if item.at_archives?

      options = []
      if item.checkoutable?
        options << :pickup
        options << :office if ils_group == FACULTY_EXPRESS_CODE
        options << :mail unless ils_group == COURTESY_BORROWER_CODE
        options << :scan if item.scannable?
      end
      options
    end
  end
end
