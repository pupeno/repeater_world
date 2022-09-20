module MailSafe
  def self.delivering_email(message)
    if ENV["SAFE_EMAIL_DEST"].blank?
      raise "SAFE_EMAIL_DEST needs to be defined"
    end

    safe_email_destination = ENV["SAFE_EMAIL_DEST"]

    development_information = "| TO: #{message.to.inspect}"
    if message.cc.try(:any?)
      development_information += "| CC: #{message.cc.inspect}"
    end
    if message.bcc.try(:any?)
      development_information += "| BCC: #{message.bcc.inspect}"
    end
    message.to = [safe_email_destination]
    message.cc = nil
    message.bcc = nil

    message.subject = "#{message.subject} #{development_information}"
  end
end

if Rails.application.config.action_mailer.delivery_method != :test &&
    Rails.application.config.action_mailer.delivery_method != :file &&
    ENV["DELIVER_EMAILS"] != "true"
  ActionMailer::Base.register_interceptor(MailSafe)
end
