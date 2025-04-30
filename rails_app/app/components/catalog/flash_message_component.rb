# frozen_string_literal: true

# Copied from Blacklight v8.10.1

module Catalog
  # Copied over so that we can adjust the html.erb to use
  # alert-dismissible to fix the layout issue with the
  # close "X" and fix the semantics to be button rather
  # than button_tag. We also sanitized the message so that
  # html can be passed in.
  class FlashMessageComponent < Blacklight::Component
    attr_reader :message

    with_collection_parameter :message

    def initialize(type:, message: nil)
      @message = message
      @classes = alert_class(type)
    end

    # Bootstrap 4 requires the span, but Bootstrap 5 should not have it.
    # See https://getbootstrap.com/docs/4.6/components/alerts/#dismissing
    #     https://getbootstrap.com/docs/5.1/components/alerts/#dismissing
    def button_contents
      return if helpers.controller.blacklight_config.bootstrap_version == 5

      tag.span '&times;'.html_safe, aria: { hidden: true }
    end

    def alert_class(type)
      case type.to_s
      when 'success' then 'alert-success'
      when 'notice'  then 'alert-info'
      when 'alert'   then 'alert-warning'
      when 'error'   then 'alert-danger'
      else "alert-#{type}"
      end
    end
  end
end
