require "test_helper"
require "action_mailer/test_helper"

class IntroductionsMailboxTest < ActionMailbox::TestCase
  include ActionMailer::TestHelper

  test "creates a new ArtistDraft when no existing artist" do
    mock_client = Minitest::Mock.new
    mock_client.expect(:generate, gemini_response) do |args| true end

    GeminiClient.stub(:new, mock_client) do
      assert_difference [ "ArtistDraft.count" ], 1 do
        receive_inbound_email_from_mail \
          from: "new_artist@example.com",
          to: "introduction@inbound.example.com",
          subject: "Intro from new artist",
          body: "Bla bla bla..."
      end
    end

    artist_draft = ArtistDraft.last
    assert_equal "new_artist@example.com", artist_draft.email_address
    assert_mock mock_client
  end

  test "does not create a new ArtistDraft when email taken by ArtistDraft" do
    existing_artist_draft_email = artist_drafts(:monet).email_address

    assert_no_difference [ "ArtistDraft.count" ] do
        receive_inbound_email_from_mail \
          from: existing_artist_draft_email,
          to: "introduction@inbound.example.com",
          subject: "Intro from new artist",
          body: "Bla bla bla..."
    end
  end

  test "does not create a new ArtistDraft when email taken by Artist" do
    existing_artist_email = artists(:carolyn).email_address

    assert_no_difference [ "ArtistDraft.count" ] do
      receive_inbound_email_from_mail \
        from: existing_artist_email,
        to: "introduction@inbound.example.com",
        subject: "Intro from new artist",
        body: "Bla bla bla..."
    end
  end

  test "creates ArtistDraft with attached image" do
    image_content = file_fixture("images/haystacks_sunset.jpg").read

    mock_client = Minitest::Mock.new
    mock_client.expect(:generate, gemini_response) do |args| true end

    GeminiClient.stub(:new, mock_client) do
      assert_difference [ "ArtistDraft.count" ], 1 do
        receive_inbound_email_from_mail do
          from    "artist_with_image@example.com"
          to      "introduction@inbound.example.com"
          subject "Introduction with Image"
          body    "Here's my portfolio image."
          add_file filename: "my-portfolio.jpg", content: image_content, content_type: "image/jpeg"
        end
      end
    end

    artist_draft = ArtistDraft.last
    assert_equal "artist_with_image@example.com", artist_draft.email_address
    assert_equal 5, artist_draft.artworks.count
    assert_equal "my-portfolio.jpg", artist_draft.artworks.first.filename.to_s
    assert_equal "image/jpeg", artist_draft.artworks.first.content_type
    assert_mock mock_client
  end

  test "sends confirmation email after creating ArtistDraft" do
    mock_client = Minitest::Mock.new
    mock_client.expect(:generate, gemini_response) do |args| true end

    mock_mailer = Minitest::Mock.new
    mock_mailer.expect(:deliver_later, true) do
      dummy_email = Mail.new do
        from    "expected_sender@example.com"
        to      "new_artist@example.com"
        subject "Expected Email Subject"
        body    "This is a dummy email body for testing delivery."
      end
      ActionMailer::Base.deliveries << dummy_email
    end

    mock_delivery_method = Minitest::Mock.new
    mock_delivery_method.expect(:notify, mock_mailer)

    ArtistDraftMailer.stub(:with, mock_delivery_method) do
      GeminiClient.stub(:new, mock_client) do
        assert_emails 1 do
          assert_difference [ "ArtistDraft.count" ], 1 do
            receive_inbound_email_from_mail \
              from: "new_artist@example.com",
              to: "introduction@inbound.example.com",
              subject: "Intro from artist",
              body: "Hoping to join your platform"
          end
        end
      end
    end

    assert_equal "new_artist@example.com", ArtistDraft.last.email_address
    assert_mock mock_client
    assert_mock mock_mailer
    assert_mock mock_delivery_method
  end

  test "sends a different email when not an introduction" do
    mock_client = Minitest::Mock.new
    mock_client.expect(:generate, gemini_response_not_intro) do |args| true end

    mock_mailer = Minitest::Mock.new
    mock_mailer.expect(:deliver_later, true) do
      dummy_email = Mail.new do
        from    "expected_sender@example.com"
        to      "new_artist@example.com"
        subject "Expected Email Subject"
        body    "This is a dummy email body for testing delivery."
      end
      ActionMailer::Base.deliveries << dummy_email
    end

    ArtistDraftMailer.stub(:notify_not_intro, mock_mailer) do
      GeminiClient.stub(:new, mock_client) do
        assert_emails 1 do
          assert_no_difference [ "ArtistDraft.count" ] do
            receive_inbound_email_from_mail \
              from: "client@example.com",
              to: "introduction@inbound.example.com",
              subject: "Query about order #12345",
              body: "This is NOT an introduction"
          end
        end
      end
    end

    assert_mock mock_client
    assert_mock mock_mailer
  end

  test "sends a different email when something goes wrong with gemini" do
    mock_client = Minitest::Mock.new
    mock_client.expect(:generate, nil) do |args|
      raise GeminiClient::APIError.new("API call failed")
    end

    mock_mailer = Minitest::Mock.new
    mock_mailer.expect(:deliver_later, true) do
      dummy_email = Mail.new do
        from    "expected_sender@example.com"
        to      "new_artist@example.com"
        subject "Expected Email Subject"
        body    "This is a dummy email body for testing delivery."
      end
      ActionMailer::Base.deliveries << dummy_email
    end

    ArtistDraftMailer.stub(:notify_gemini_error, mock_mailer) do
      GeminiClient.stub(:new, mock_client) do
        assert_emails 1 do
          assert_no_difference [ "ArtistDraft.count" ] do
            receive_inbound_email_from_mail \
              from: "client@example.com",
              to: "introduction@inbound.example.com",
              subject: "Genuine intro",
              body: "This is an intro but something will break.  Sad times"
          end
        end
      end
    end

    assert_mock mock_client
    assert_mock mock_mailer
  end

  test "sends a different email when gemini not configured properly" do
    mock_mailer = Minitest::Mock.new
    mock_mailer.expect(:deliver_later, true) do
      dummy_email = Mail.new do
        from    "expected_sender@example.com"
        to      "new_artist@example.com"
        subject "Expected Email Subject"
        body    "This is a dummy email body for testing delivery."
      end
      ActionMailer::Base.deliveries << dummy_email
    end

    ArtistDraftMailer.stub(:notify_gemini_error, mock_mailer) do
      GeminiClient.stub(:new, ->() do
        raise GeminiClient::ConfigurationError.new("Missing google cloud credentials")
      end) do
        assert_emails 1 do
          assert_no_difference [ "ArtistDraft.count" ] do
            receive_inbound_email_from_mail \
              from: "client@example.com",
              to: "introduction@inbound.example.com",
              subject: "Genuine intro",
              body: "This is an intro but something will break.  Sad times"
          end
        end
      end
    end

    assert_mock mock_mailer
  end

  private

  def gemini_response
    JSON.parse(file_fixture("gemini_structured_response.json").read)
  end

  def gemini_response_not_intro
    JSON.parse(file_fixture("gemini_structured_response_not_intro.json").read)
  end
end
