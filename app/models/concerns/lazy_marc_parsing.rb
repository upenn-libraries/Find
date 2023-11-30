# frozen_string_literal: true

# Given a Solr field defined in MARCXML_FIELD, this module provides a #marc method that receives
# a parameter corresponding to a method call that a PennMARC parser will respond to.
# The parser and the MARC::Record are memoized but the parsed values are not. Eventually we could
# do that using instance_variable_set or somesuch.
module LazyMARCParsing
  extend ActiveSupport::Concern

  MARCXML_FIELD = 'marcxml_marcxml'

  # @param [Symbol, String] field
  # @return [Object]
  def marc(field, *opts)
    if opts.any?
      pennmarc.public_send(field.to_sym, marc_record, **opts.first)
    else
      pennmarc.public_send(field.to_sym, marc_record)
    end
  end

  private

  # @return [MARC::Record]
  def marc_record
    @marc_record ||= MARC::XMLReader.new(StringIO.new(self[MARCXML_FIELD].first)).first
  end

  # @return [PennMARC::Parser]
  def pennmarc
    @pennmarc ||= PennMARC::Parser.new
  end
end
