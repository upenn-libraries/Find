# frozen_string_literal: true

module Catalog
  # Extend BL's class to allow us to customize the template for integration into a toolbar
  class ServerAppliedParamsComponent < Blacklight::SearchContext::ServerAppliedParamsComponent; end
end
