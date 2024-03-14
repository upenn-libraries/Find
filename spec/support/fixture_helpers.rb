# frozen_string_literal: true

module FixtureHelpers
  # @param [String] filename
  # @return [String]
  def json_fixture(filename, directory = nil)
    filename = "#{filename}.json" unless filename.ends_with?('.json')
    dirs = ['json', directory.to_s, filename].compact_blank
    File.read(File.join(fixture_path, dirs))
  end
end
