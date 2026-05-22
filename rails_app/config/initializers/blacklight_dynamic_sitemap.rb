# frozen_string_literal: true

config = BlacklightDynamicSitemap::Engine.config
# set the lastmod field to the indexed date
config.last_modified_field = 'indexed_date_s'
# format last modified date to W3C Datetime https://www.w3.org/TR/NOTE-datetime
config.format_last_modified = lambda { |raw_last_modified|
  Time.zone.parse(raw_last_modified).strftime '%Y-%m-%dT%H:%M:%S%:z'
}
