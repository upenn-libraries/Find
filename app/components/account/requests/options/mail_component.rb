# frozen_string_literal: true

module Account
  module Requests
    module Options
      # mail delivery component logic
      class MailComponent < ViewComponent::Base
        attr_accessor :form

        def initialize(form:)
          @form = form
        end
      end
    end
  end
end
