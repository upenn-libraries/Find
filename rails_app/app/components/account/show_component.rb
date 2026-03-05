# frozen_string_literal: true

module Account
  # Renders the navigation cards on the account show page.
  class ShowComponent < ViewComponent::Base
    delegate :courtesy_borrower?, to: :user

    # @param user [User]
    def initialize(user:)
      @user = user
    end

    private

    attr_reader :user
  end
end
