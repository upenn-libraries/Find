# frozen_string_literal: true

class CreatorSuggestController < ApplicationController
  # GET /creator_suggest?q=...
  def suggest
    Rails.logger.warn 'WE REACHED THE CONTROLLER!'
    q = params[:q].to_s
    results =
      if q.blank?
        []
      else
        Rails.cache.fetch(['creator_suggest', q], expires_in: 60.seconds) do
          CreatorSuggest::Matcher.new.call(q)
        end
      end

    render(CreatorSuggest::Component.new(results: results), layout: false)
  rescue StandardError => e
    Rails.logger.warn("[CreatorSuggestsController] #{e.class}: #{e.message}")
    render(CreatorSuggest::Component.new(results: []), layout: false)
  end
end
