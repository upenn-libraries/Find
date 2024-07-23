# frozen_string_literal: true

# Controller for the Library Info component
class LibraryController < ApplicationController
  # GET /library/:code
  # Returns a library's location information
  def info
    respond_to do |format|
      format.html do
        @code = code
        render(Library::InfoComponent.new(library_code: code), layout: false)
      end
    end
  end
end
