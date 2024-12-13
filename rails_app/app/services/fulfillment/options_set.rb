# frozen_string_literal: true

module Fulfillment
  # Based on an item and a user, build a set of fulfillment options
  class OptionsSet
    include Enumerable

    attr_reader :item, :user, :options

    # @param item [Inventory::Item]
    # @param user [User, nil]
    def initialize(item:, user:)
      raise StandardError('OptionSet called without an Item') unless item

      @item = item
      @user = user
      @options = build_options
    end

    def each(&)
      options.each(&)
    end

    # @return [ActiveSupport::ArrayInquirer]
    def inquiry
      @inquiry = options.inquiry
    end

    # Does this options set represent a deliverable item? If no user is provided, delivery is impossible.
    # @return [Boolean]
    def deliverable?
      return false unless user

      (options & Options::Deliverable.all).any?
    end

    # Does this options set represent a restricted access item? So far there is only one restricted option per item,
    # but this logic matches the deliverable? method above for future extensibility.
    # @return [Boolean]
    def restricted?
      (options & Options::Restricted.all).any?
    end

    private

    # @return [Array<Symbol>]
    def build_options
      restricted_options = [restricted_option].compact_blank

      # Non-logged-in users should still see restricted access options
      return restricted_options if !user || restricted_options.any?

      delivery_options
    end

    # @return [Symbol, nil]
    def restricted_option
      return Options::Restricted::AEON if item.location.aeon?
      return Options::Restricted::ARCHIVES if item.location.archives?
      return Options::Restricted::HSP if item.location.hsp?
      return Options::Restricted::REFERENCE if item.item_policy == Settings.fulfillment.policies.reference
      return Options::Restricted::RESERVE if item.item_policy == Settings.fulfillment.policies.reserve

      Options::Restricted::ONSITE if non_circulating_item?
    end

    # @return [Array<Symbol>]
    def delivery_options
      return [courtesy_borrower_option] if user.courtesy_borrower?

      options = pickup_option
      options << Options::Deliverable::MAIL unless item_material_type_excluded_from_ill?
      options << Options::Deliverable::OFFICE if user.faculty_express?
      options << Options::Deliverable::ELECTRONIC unless item_material_type_excluded_from_scanning?
      options
    end

    # Determine the "pickup" option to use - ILL pickup means the pickup request should go to the ILL department. In
    # that case, we need to be sure the item is also one that can be expected to be fulfilled via ILL (not an odd
    # material type)
    # @return [Array]
    def pickup_option
      if item.in_place?
        [Options::Deliverable::PICKUP]
      elsif item_material_type_excluded_from_ill?
        []
      else
        [Options::Deliverable::ILL_PICKUP]
      end
    end

    # @return [Symbol]
    def courtesy_borrower_option
      Options::Deliverable::PICKUP if item.in_place?
    end

    # @return [Boolean]
    def not_loanable?
      item.user_due_date_policy == Settings.fulfillment.due_date_policy.not_loanable
    end

    # Consider an Item non-circulating if it has one of our non-circulating policies (distinct from reserves/reference
    # which are handled separately) OR if it is in place ('available') but also has a Not Loanable due date policy.
    # This latter criteria is intended to catch other, less common policies that also limit circulation.
    # @return [Boolean]
    def non_circulating_item?
      item.item_policy.in?([Settings.fulfillment.policies.non_circ, Settings.fulfillment.policies.in_house]) ||
        (item.in_place? && not_loanable?)
    end

    # @return [String, nil]
    def material_type_value
      item.physical_material_type['value']
    end

    # @return [Boolean]
    def item_material_type_excluded_from_ill?
      return false if material_type_value.blank?

      material_type_value.in?(Settings.fulfillment.ill.excluded_material_types)
    end

    # @return [Boolean]
    def item_material_type_excluded_from_scanning?
      return false if material_type_value.blank?

      material_type_value.in?(Settings.fulfillment.scan.excluded_material_types)
    end
  end
end
