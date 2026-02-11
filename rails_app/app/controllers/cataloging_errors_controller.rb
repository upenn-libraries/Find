# frozen_string_literal: true

# Allows users to report cataloging errors
class CatalogingErrorsController < ApplicationController
  before_action :authenticate_user!

  def create
    CatalogingErrorsMailer.report(
      user: current_user,
      mms_id: params[:mms_id],
      message: params[:message]
    ).deliver_now

    redirect_to_document(flash: t('cataloging_errors.flash.success'))
  rescue StandardError
    redirect_to_document(flash: t('cataloging_errors.flash.error'))
  end

  private

  def redirect_to_document(flash:)
    redirect_back(
      fallback_location: solr_document_path(params[:mms_id]),
      alert: flash
    )
  end
end
