# frozen_string_literal: true

module Account
  # Renders the navigation cards on the account show page. The home page reuses them as quick links.
  class ShowComponent < ViewComponent::Base
    attr_reader :user, :heading_tag

    delegate :courtesy_borrower?, to: :user

    # @param user [User, nil]
    # @param heading_tag [Symbol] heading level for each card, so the cards fit under a section heading
    def initialize(user:, heading_tag: :h2)
      @user = user
      @heading_tag = heading_tag
    end
  end
end
