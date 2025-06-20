# frozen_string_literal: true

module FixtureHelpers
  # @param [String] filename
  # @return [String]
  def json_fixture(filename, directory = nil)
    filename = "#{filename}.json" unless filename.ends_with?('.json')
    dirs = ['json', directory.to_s, filename].compact_blank
    File.read(File.join(fixture_paths, dirs))
  end

  # @param [String] filename
  # @return [String]
  def marc_xml_fixture(filename, directory = nil)
    filename = "#{filename}.xml" unless filename.ends_with?('.xml')
    dirs = ['marc_xml', directory.to_s, filename].compact_blank
    File.read(File.join(fixture_paths, dirs))
  end

  # @param [String] filename
  # @return [String]
  def sru_xml_fixture(filename, directory = nil)
    filename = "#{filename}.xml" unless filename.ends_with?('.xml')
    dirs = ['sru_xml', directory.to_s, filename].compact_blank
    File.read(File.join(fixture_paths, dirs))
  end

  # @param [String] filename
  # @return [String]
  def tsv_fixture(filename, directory = nil)
    filename = "#{filename}.tsv" unless filename.ends_with?('.tsv')
    dirs = ['tsv', directory.to_s, filename].compact_blank
    File.read(File.join(fixture_paths, dirs))
  end
end
