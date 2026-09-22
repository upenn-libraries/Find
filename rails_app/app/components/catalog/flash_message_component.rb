# frozen_string_literal: true

module Catalog
  # Extends class from Blacklight v9.2.1 to allow for message sanitization, enabling display of limited HTML
  class FlashMessageComponent < Blacklight::System::FlashMessageComponent
    def before_render
      with_message { sanitize(@message) } if @message
    end
  end
end
