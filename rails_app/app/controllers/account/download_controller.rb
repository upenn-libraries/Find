# frozen_string_literal: true

module Account
  # Controller for downloading files using the ActionController::Live features.
  #
  # In order to stream files from another website without saving them in memory first we have to use features
  # only available in ActionController::Live. By mixing in this class, we are required to explicitly set headers
  # for all actions. This would be undesirable for most actions, which is why this action had to be moved to
  # its own controller.
  class DownloadController < AccountController
    include ActionController::Live

    # Download PDF of ILL scan
    # GET /account/requests/ill/transaction/:id/download
    def scan
      shelf = Shelf::Service.new(current_user.uid)
      @entry = shelf.find(:ill, :transaction, params[:id])

      return head :not_found unless @entry.pdf_available?

      send_stream(filename: "#{@entry.id}.pdf", type: :pdf) do |stream|
        @entry.pdf do |chunk, *|
          stream.write chunk
        end
      end
      # update transaction history in illiad to show that the pdf was downloaded
      shelf.mark_pdf_viewed(params[:id])
    end
  end
end
