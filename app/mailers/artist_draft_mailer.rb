class ArtistDraftMailer < ApplicationMailer
  include PostmarkRails::TemplatedMailerMixin

  def notify
    @artist_draft = params[:artist_draft]
    token = @artist_draft.generate_token_for(:ownership)

    self.template_model = {
      name: @artist_draft.first_name,
      draft_url: artist_draft_url(@artist_draft, token: token),
      support_email: "support@otterkin.co.uk",
      sender_name: "Jed"
    }

    mail(
      to: @artist_draft.email_address,
      message_stream: "artist-transactional-stream",
      postmark_template_alias: "artist_draft_notify"
    )
  end

  def notify_existing
    @artist_draft = params[:artist_draft]
    token = @artist_draft.generate_token_for(:ownership)

    self.template_model = {
      name: @artist_draft.first_name,
      draft_url: artist_draft_url(@artist_draft, token: token),
      support_email: "support@otterkin.co.uk",
      sender_name: "Jed"
    }

    mail(
      to: @artist_draft.email_address,
      message_stream: "artist-transactional-stream",
      postmark_template_alias: "artist_draft_notify_existing"
    )
  end

  def notify_not_intro(email_address)
    self.template_model = {
      subject: "About your introduction...",
      name: nil,
      text: not_intro_text,
      action: nil,
      support_email: "support@otterkin.co.uk",
      sender_name: "Jed"
    }

    mail(
      to: email_address,
      message_stream: "artist-transactional-stream",
      postmark_template_alias: "text_and_action"
    )
  end

  def  notify_gemini_error(email_address)
    self.template_model = {
      subject: "About your introduction...",
      name: nil,
      text: gemini_error_text,
      action: nil,
      support_email: "support@otterkin.co.uk",
      sender_name: "Jed"
    }

    mail(
      to: email_address,
      message_stream: "artist-transactional-stream",
      postmark_template_alias: "text_and_action"
    )
  end

  private

  def not_intro_text
    <<~NOT_EXISTING_TEXT
      We've received your email, but it has not been flagged as an artist
      introduction, and so we have not drafted up an artist page for you.  We'll
      make sure to respond once we've seen this however.
    NOT_EXISTING_TEXT
  end

  def gemini_error_text
    <<~GEMINI_ERROR_TEXT
      We've received your email, but something went wrong when
      trying to draft up an artist profile for you - terribly
      sorry!  We'll get in touch ASAP.
    GEMINI_ERROR_TEXT
  end
end
