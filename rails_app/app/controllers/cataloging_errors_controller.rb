# frozen_string_literal: true

# Allows users to report cataloging errors
class CatalogingErrorsController < ApplicationController
  before_action :authenticate_user!

  def create
    CatalogingErrorsMailer.report(
      user: current_user,
      mms_id: params[:mms_id],
      # TODO: not everything will have a holding id?
      holding_id: params[:holding_id],
      message: params[:message]
    ).deliver_now

    redirect_back fallback_location: solr_document_path(params[:mms_id]),
                  notice: t('cataloging_errors.flash.success')
  rescue StandardError
    redirect_back(
      fallback_location: solr_document_path(params[:mms_id]),
      alert: t('cataloging_errors.flash.failure')
    )
  end
end
