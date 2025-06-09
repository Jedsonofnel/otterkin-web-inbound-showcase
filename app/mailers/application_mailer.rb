class ApplicationMailer < ActionMailer::Base
  include EnvironmentHelper

  default from: -> { noreply_from_address }
  layout "mailer"

  # send the message to me in development instead
  before_deliver :development_redirect

  private

  def development_redirect
    if dev?
      message.to = message.to.select { |email| email.split("@").last == "otterkin.art" }
      message.to = [ Rails.application.credentials.dig(:dev_env_email) || "test@example.com" ] if message.to.empty?
    end

    message.to = [ Rails.application.credentials.dig(:development_email) ] if Rails.env.development?
  end
end
