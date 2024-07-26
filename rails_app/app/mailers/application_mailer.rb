# frozen_string_literal: true

# Parent mailer class for application mailers
class ApplicationMailer < ActionMailer::Base
  default from: Settings.email.from_address
  layout 'mailer'
end
