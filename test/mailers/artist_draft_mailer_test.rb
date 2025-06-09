require "test_helper"

class ArtistDraftMailerTest < ActionMailer::TestCase
  test "sends notify email" do
    artist_draft = artist_drafts(:monet)
    email = ArtistDraftMailer.with(artist_draft: artist_draft).notify

    assert_emails 1 do
      email.deliver_now
    end

    assert_not ActionMailer::Base.deliveries.empty?, "Email should be sent"
    assert_equal [ artist_draft.email_address ], email.to, "Email should be sent to the correct address"
  end

  test "sends notify_existing email" do
    artist_draft = artist_drafts(:monet)
    email = ArtistDraftMailer.with(artist_draft: artist_draft).notify_existing

    assert_emails 1 do
      email.deliver_now
    end

    assert_not ActionMailer::Base.deliveries.empty?, "Email should be sent"
    assert_equal [ artist_draft.email_address ], email.to, "Email should be sent to the correct address"
  end

  test "sends notify_not_intro email" do
    email_address = "test@testes.com"
    email = ArtistDraftMailer.notify_not_intro(email_address)

    assert_emails 1 do
      email.deliver_now
    end

    assert_not ActionMailer::Base.deliveries.empty?, "Email should be sent"
    assert_equal [ email_address ], email.to, "Email should be sent to the correct address"
  end

  test "sends notify_gemini_error email" do
    email_address = "test@testes.com"
    email = ArtistDraftMailer.notify_gemini_error(email_address)

    assert_emails 1 do
      email.deliver_now
    end

    assert_not ActionMailer::Base.deliveries.empty?, "Email should be sent"
    assert_equal [ email_address ], email.to, "Email should be sent to the correct address"
  end
end
