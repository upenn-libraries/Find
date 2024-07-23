# frozen_string_literal: true

# Mail actions for Requests
class RequestMailer < ApplicationMailer
  # Send a confirmation email to the requester
  # @param [Fulfillment::Outcome] outcome
  def confirmation_email(outcome:)
    @outcome = outcome
    mail(to: @outcome.request.requester.email, subject: I18n.t('fulfillment.outcome.email.confirmation_subject'))
  end
end
