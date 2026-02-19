# frozen_string_literal: true

# Copied from Blacklight v9.0

module Catalog
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
    # so that we don't have to do c.with_search_bar() in the call.
    def before_render
      with_search_bar unless search_bar
    end

    # Memoize alerts to prevent doubling database queries
    # @return [ActiveRecord::Relation<Alert>]
    def alerts
      @alerts ||= Alert.all
    end

    # Join alert text values for display
    # @return [String]
    def joined_alert_values
      alerts.filter_map { |alert| alert.text if alert.on }.join
    end

    # Check if the alert has been dismissed. Since there are two alerts that are joined into one, we just look for
    # the most recently updated alert and compare it to the session variable.
    # @return [TrueClass, FalseClass]
    def alerts_dismissed?
      return false if session[:alert_dismissed_at].blank?

      alerts.max_by(&:updated_at).updated_at < session[:alert_dismissed_at]
    end
  end
end
