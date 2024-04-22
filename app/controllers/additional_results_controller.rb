# frozen_string_literal: true

class AdditionalResultsController < ApplicationController
  # Renders additional results from a specified source for use in the Additional Results component
  def results
    respond_to do |format|
      source_id = params[:source_id] || 'summon' # Default to Articles+ results

      format.html { render(AdditionalResults::ResultsSourceComponent.new(source_id), layout: false) }
    end
  end
end
