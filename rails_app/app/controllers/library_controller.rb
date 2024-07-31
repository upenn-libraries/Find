# frozen_string_literal: true

# Controller for the Library Info component
class LibraryController < ApplicationController
  # GET /library/:code
  # Returns a library's location information
  def info
    return if params[:code].blank?

    respond_to do |format|
      format.html do
        render(Library::InfoComponent.new(library_code: params[:code].to_s), layout: false)
      end
    end
  end
end
