# frozen_string_literal: true

module FixtureHelpers
  # @param filename [String]
  # @param namespace [String, Symbol, nil]
  # @param directory [String, Symbol, nil]
  # @return [String]
  def json_fixture(filename, namespace: nil, directory: nil)
    filename = "#{filename}.json" unless filename.ends_with?('.json')
    dirs = [namespace.to_s, 'json', directory.to_s, filename].compact_blank
    File.read(File.join(fixture_paths, dirs))
  end

  # @param filename [String]
  # @param namespace [String, Symbol, nil]
  # @param directory [String, Symbol, nil]
  # @return [String]
  def marc_xml_fixture(filename, namespace: nil, directory: nil)
    filename = "#{filename}.xml" unless filename.ends_with?('.xml')
    dirs = [namespace.to_s, 'marc_xml', directory.to_s, filename].compact_blank
    File.read(File.join(fixture_paths, dirs))
  end

  # @param filename [String]
  # @param namespace [String, Symbol, nil]
  # @param directory [String, Symbol, nil]
  # @return [String]
  def sru_xml_fixture(filename, namespace: nil, directory: nil)
    filename = "#{filename}.xml" unless filename.ends_with?('.xml')
    dirs = [namespace.to_s, 'sru_xml', directory.to_s, filename].compact_blank
    File.read(File.join(fixture_paths, dirs))
  end

  # @param [String] filename
  # @param [Symbol, String] format - :csv or :tsv
  # @param [String, nil] directory
  # @return [String]
  def tabular_fixture(filename, namespace: nil, format: :csv, directory: nil)
    filename = "#{filename}.#{format}" unless filename.ends_with?(format.to_s)
    dirs = [namespace.to_s, format.to_s, directory.to_s, filename].compact_blank
    File.read(File.join(fixture_paths, dirs))
  end
end
