# frozen_string_literal: true

module Account
  # Controller for submitting new Alma/ILL requests and displaying the "shelf" (containing Alma requests &
  # Illiad transactions & Alma loans).
  class RequestsController < AccountController
    # Returns form for initializing a new request. TODO: May return a turbo frame response.
    # GET /account/requests/new
    def new; end

    # Form for initializing an ILL form.
    # GET /account/requests/ill/new
    def ill; end

    # Submit endpoint for a request form.
    # POST /account/requests
    def create
      # Submits via the request broker service. The service will take care of submitting it to the appropriate system.
      # TODO: Redirects to /account/shelf
    end

    # List all shelf entries. Supports sort & filter params.
    # GET /account/requests and GET /account/shelf
    def index; end

    # Show all details of a shelf entry. May not be needed based on index page design.
    # GET /account/requests/:system/:id
    def show; end

    # Renew an Alma loan.
    # POST /account/requests/ils/:id/renew
    def renew; end

    # Cancel an Alma HOLD request.
    # DELETE /account/requests/ils/:id
    def delete; end
  end
end
