# frozen_string_literal: true

# Concern centralizing methods that create a MARC::Record object and parse data out of it.
module MARCParsing
  extend ActiveSupport::Concern

  MARCXML_FIELD = 'marcxml_marcxml'

  # Given a Solr field defined in MARCXML_FIELD, this method receives a parameter corresponding to a
  # method call that a PennMARC parser will respond to.
  # @todo Notably, the parsed values are not memoized. If these lazily-parsed values end up
  #       being used more than once, there could be a benefit to memoizing them.
  #
  # @param [Symbol, String] field
  # @param [Array] opts params to be sent to PennMARC method
  # @return [Object]
  def marc(field, *opts)
    raise NameError, "PennMARC parser does not support calling #{field}" unless pennmarc.respond_to? field

    if opts.any?
      pennmarc.public_send(field.to_sym, marc_record, **opts.first)
    else
      pennmarc.public_send(field.to_sym, marc_record)
    end
  end

  # Returns MARC record.
  #
  # @return [MARC::Record]
  def marc_record
    @marc_record ||= MARC::XMLReader.new(StringIO.new(self[MARCXML_FIELD])).first
  end

  private

  # @return [PennMARC::Parser]
  def pennmarc
    @pennmarc ||= PennMARC::Parser.new
  end
end
