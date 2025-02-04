# frozen_string_literal: true

# Helper for Discover Penn functionality
module Discover
  module DiscoverHelper
    def search_params?
      params[:q].present?
    end
  end
end