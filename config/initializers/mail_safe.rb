# Copyright 2023, Flexpoint Tech
#
# This file is part of Repeater World.
#
# Repeater World is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General
# Public License as published by the Free Software Foundation, either version 3 of the License.
#
# Repeater World is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied 
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more 
# details.
#
# You should have received a copy of the GNU Affero General Public License along with Repeater World. If not, see
# <https://www.gnu.org/licenses/>.

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
