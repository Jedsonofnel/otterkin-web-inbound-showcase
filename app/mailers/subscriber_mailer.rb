class SubscriberMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin
  default from: -> { welcome_from_address }

  def welcome
    @subscriber = params[:subscriber]

    self.template_model = {
      name: @subscriber.first_name,
      commonplace_url: articles_url,
      action_url: confirm_subscriber_url(token: @subscriber.generate_token_for(:confirm)),
      support_email: "support@otterkin.co.uk",
      sender_name: "Jed",
      artist: @subscriber.artist
    }

    mail(
      to: @subscriber.email_address,
      tag: "welcome",
      message_stream: "outbound",
      postmark_template_alias: "subscriber_welcome",
      reply_to: "introduction@#{inbound_email_domain}"
    )
  end

  def notify_newsletter(recipient_email = nil)
    @subscriber = params[:subscriber]
    @newsletter = params[:newsletter]

    image = @newsletter.article.cover_image.variant(resize_to_fill: [ 400, 200 ])

    self.template_model = {
      name: @subscriber.first_name,
      newsletter_title: @newsletter.article.title,
      newsletter_cover_image_url: url_for(image),
      newsletter_blurb: @newsletter.article.blurb,
      newsletter_url: newsletter_url(@newsletter),
      sender_name: @newsletter.article.user.first_name
    }

    mail(
      to: recipient_email || @subscriber.email_address,
      from: "updates@#{email_domain}",
      tag: "notify",
      message_stream: "broadcast",
      postmark_template_alias: "subscriber_notify_newsletter"
    )
  end

  def invite_artist
    @subscriber = params[:subscriber]

    self.template_model = {
      name: @subscriber.first_name,
      onboard_url: new_artist_registration_url(token: @subscriber.generate_token_for(:invitation)),
      support_email: "support@otterkin.co.uk"
    }

    mail(
      to: @subscriber.email_address,
      tag: "invite",
      message_stream: "outbound",
      postmark_template_alias: "subscriber_artist_invite"
    )
  end
end
