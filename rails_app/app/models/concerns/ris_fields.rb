# frozen_string_literal: true

# Fields in the RIS format download file
module RisFields
  extend ActiveSupport::Concern

  # The RIS field mapping that will be defined in solr_document
  module ClassMethods
    def ris_field_mappings
      @ris_field_mappings ||= {}
    end
  end
end
