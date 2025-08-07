# frozen_string_literal: true

# Mail actions for Document Delivery fulfillment
class DocdelMailer < ApplicationMailer
  # Send a document delivery request email to the requester
  # @param request [Fulfillment::Request]
  def docdel_email(request:)
    @params = request.params
    @user = request.requester
    mail(
      to: Settings.fulfillment.docdel.email,
      reply_to: @user.email,
      subject: I18n.t('fulfillment.docdel.email.subject')
    )
  end
end
