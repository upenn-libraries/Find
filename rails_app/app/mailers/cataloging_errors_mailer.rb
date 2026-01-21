# frozen_string_literal: true

# Cataloging errors mailer
class CatalogingErrorsMailer < ApplicationMailer
  def report(user:, mms_id:, message:, holding_id: nil)
    @user = user
    @mms_id = mms_id
    @message = message
    @holding_id = holding_id

    mail(
      to: Settings.cataloging_errors.email,
      subject: t('cataloging_errors.email.subject', mms_id: @mms_id)
    )
  end
end
