# frozen_string_literal: true

# Controller for the Additional Results component
class AdditionalResultsController < ApplicationController
  # Renders additional results from a specified source for use in the Additional Results component
  def results
    respond_to do |format|
      source = params[:source] || 'summon' # Default to Articles+ results

      format.html { render(AdditionalResults::ResultsSourceComponent.new(source), layout: false) }
    end
  end
end
