# frozen_string_literal: true

# Copied from Blacklight version 8.1.0

module Find
  # Our HeaderComponent that displays the Web Component header and the search bar component
  class HeaderComponent < Blacklight::Component
    renders_one :search_bar, lambda { |component: Blacklight::SearchNavbarComponent|
      component.new(blacklight_config: blacklight_config)
    }

    attr_reader :blacklight_config, :user

    # @param blacklight_config [Blacklight::Configuration]
    # @param user [User]
    def initialize(blacklight_config:, user:)
      @blacklight_config = blacklight_config
      @user = user
    end

    # Hack from Blacklight::HeaderComponent so that the default lambdas are triggered
    # so that we don't have to do c.with_top_bar() in the call.
    def before_render
      set_slot(:search_bar, nil) unless search_bar
    end

    # Memoize alerts to prevent doubling database queries
    # @return [Array]
    def alerts
      @alerts ||= Alert.all
    end

    # Join alert text values for display
    # @return [String]
    def joined_alert_values
      alerts.filter_map { |alert| alert.text if alert.on }.join
    end
  end
end
