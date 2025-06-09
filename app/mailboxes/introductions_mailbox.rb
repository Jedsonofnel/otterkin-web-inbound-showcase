class IntroductionsMailbox < ApplicationMailbox
  def process
    sender_email = mail.from.first
    text_body = extract_email_body

    return if handle_existing(sender_email)

    @artist_draft = ArtistDraft.new(email_address: sender_email)
    @artist_draft.extract_from_email_data(text_body: text_body, subject: mail.subject)

    return notify_gemini_error(sender_email) if gemini_processing_failed?

    return notify_not_intro(sender_email) unless @artist_draft.introduction

    attach_artworks_to_draft

    if @artist_draft.save
      ArtistDraftMailer.with(artist_draft: @artist_draft).notify.deliver_later
    else
      logger.error "Failed to create ArtistDraft for #{sender_email}. Errors: #{@artist_draft.errors.full_messages.to_sentence}"
    end
  end

  private

  def extract_email_body
    mail.text_part ? mail.text_part.decoded : mail.body.decoded
  end

  def handle_existing(email)
    artist_draft = ArtistDraft.find_by(email_address: email)

    if artist_draft.present?
      ArtistDraftMailer.with(artist_draft: artist_draft).notify_existing.deliver_later
      true
    else
      false
    end
  end

  def gemini_processing_failed?
    @artist_draft.errors.added?(:base, :gemini_api_error) ||
    @artist_draft.errors.added?(:base, :gemini_parsing_error) ||
    @artist_draft.errors.added?(:base, :gemini_configuration_error)
  end

  def notify_gemini_error(recipient_email)
    ArtistDraftMailer.notify_gemini_error(recipient_email).deliver_later
  end

  def notify_not_intro(recipient_email)
    ArtistDraftMailer.notify_not_intro(recipient_email).deliver_later
  end

  def attach_artworks_to_draft
    mail.attachments.each do |attachment|
      if attachment.content_type.to_s.start_with?("image/")
        @artist_draft.artworks.attach(
          io: StringIO.new(attachment.decoded),
          filename: attachment.filename,
          content_type: attachment.content_type
        )
      end
    end
  end
end
