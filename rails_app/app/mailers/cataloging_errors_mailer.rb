# frozen_string_literal: true

# Cataloging errors mailer
class CatalogingErrorsMailer < ApplicationMailer
  def report(user:, mms_id:, message:)
    @user = user
    @mms_id = mms_id
    @message = message

    mail(
      to: Settings.cataloging_errors.email,
      subject: t('cataloging_errors.email.subject', mms_id: @mms_id)
    )
  end
end
