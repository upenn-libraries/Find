# frozen_string_literal: true

# Copied from Blacklight v9.0

module Catalog
  # Copied over so that we can adjust the html.erb to use
  # alert-dismissible to fix the layout issue with the
  # close "X" and fix the semantics to be a button rather
  # than button_tag. We also sanitized the message so that
  # html can be passed in.
  class FlashMessageComponent < Blacklight::Component
    attr_reader :message

    with_collection_parameter :message

    def initialize(type:, message: nil)
      @message = message
      @classes = alert_class(type)
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
