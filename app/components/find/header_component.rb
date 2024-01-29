# frozen_string_literal: true

module Find
  # Our HeaderComponent that displays the Web Component header and the search bar component
  class HeaderComponent < Blacklight::Component
    renders_one :search_bar, lambda { |component: Blacklight::SearchNavbarComponent|
      component.new(blacklight_config: blacklight_config)
    }

    attr_reader :blacklight_config, :user

    # @param [Blacklight::Configuration] blacklight_config
    # @param [User] user
    def initialize(blacklight_config:, user:)
      @blacklight_config = blacklight_config
      @user = user
    end

    # Hack from Blacklight::HeaderComponentso that the default lambdas are triggered
    # so that we don't have to do c.with_top_bar() in the call.
    def before_render
      set_slot(:search_bar, nil) unless search_bar
    end
  end
end
