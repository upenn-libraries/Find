# frozen_string_literal: true

# Fields in the RIS format download file
module RisFields
  extend ActiveSupport::Concern

  module ClassMethods
    def ris_field_mappings
      @ris_field_mappings ||= {}
    end
  end

end
