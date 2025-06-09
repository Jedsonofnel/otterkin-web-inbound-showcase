require "test_helper"
require "json"

class ArtistDraftTest < ActiveSupport::TestCase
  test "first_name is required" do
    nameless = ArtistDraft.new(last_name: "Surname", email_address: "no@firstname.com")
    assert_not nameless.valid?
  end

  test "last_name is required" do
    nameless = ArtistDraft.new(first_name: "Joe", email_address: "no@lastname.com")
    assert_not nameless.valid?
  end

  test "email_address is required" do
    emailless = ArtistDraft.new(last_name: "Surname", first_name: "Joe")
    assert_not emailless.valid?
  end

  test "email_address must be unique" do
    monet = artist_drafts(:monet)
    monet_clone = ArtistDraft.new(first_name: "Not", last_name: "Claude", email_address: monet.email_address)
    assert_not monet_clone.valid?
  end

  test "extract_from_email_data works" do
    mock_client = Minitest::Mock.new
    mock_client.expect(:generate, gemini_response) do |args| true end

    GeminiClient.stub(:new, mock_client) do
      artist_draft = ArtistDraft.new(email_address: "claude@monet.art")
      artist_draft.extract_from_email_data(subject: "Hi from Claude", text_body: normal_email)

      assert_equal artist_draft.first_name, "Claude"
      assert_equal artist_draft.last_name, "Monet"
      assert_not_nil artist_draft.biography

      assert_not_nil artist_draft.data["medium_tags"]
      assert_not_nil artist_draft.data["questions"]
      assert_not_nil artist_draft.data["commission_types"]
    end
  end

  test "extract_from_email_data does not create if not an introduction" do
    mock_client = Minitest::Mock.new
    mock_client.expect(:generate, gemini_response_not_intro) do |args| true end

    GeminiClient.stub(:new, mock_client) do
      artist_draft = ArtistDraft.new(email_address: "spam@notintro.com")
      result = artist_draft.extract_from_email_data(subject: "BUSINESS OPPORTUNITY", text_body: "spam email")

      assert_not result, "extract_from_email_data should return false when not an introduction"
      assert_not artist_draft.introduction, "introduction should be set to false if not"
      assert_not artist_draft.valid?, "ArtistDraft should not be valid when not an introduction"
      assert artist_draft.errors.added?(:base, :not_an_introduction), "Should add an :not_an_introduction error to base"
      assert_not artist_draft.save, "Should not save if not an introduction"
      mock_client.verify
    end
  end

  test "extract_from_email_data returns false and adds an error on gemini api failure" do
    mock_client = Minitest::Mock.new
    mock_client.expect(:generate, nil) do |args|
      raise GeminiClient::APIError.new("API call failed")
    end

    GeminiClient.stub(:new, mock_client) do
      artist_draft = ArtistDraft.new(email_address: "api_error@test.com")
      result = artist_draft.extract_from_email_data(subject: "Test API Error", text_body: "This email should trigger API error.")

      assert_not result, "extract_from_email_data should return false on Gemini API error"
      assert artist_draft.errors.added?(:base, :gemini_api_error), "Should add a :gemini_api_error to base"
      assert_not artist_draft.save, "Artist draft should not save on Gemini API error"
      mock_client.verify
    end
  end

  test "extract_from_email_data handles gemini response error" do
    mock_client = Minitest::Mock.new
    mock_client.expect(:generate, nil) do |args|
      raise GeminiClient::MalformedResponseError.new("Error in parsing response")
    end

    GeminiClient.stub(:new, mock_client) do
      artist_draft = ArtistDraft.new(email_address: "response_error@test.com")
      result = artist_draft.extract_from_email_data(subject: "Response Error", text_body: "Should trigger an error")

      assert_not result, "extract_from_email_data should return false on Response error"
      assert artist_draft.errors.added?(:base, :gemini_parsing_error), "Should add a :gemini_parsing_error to base"
      assert_not artist_draft.save, "Artist draft should not save on parsing error"
      mock_client.verify
    end
  end

  test "extract_from_email_data handles Gemini client configuration error" do
    GeminiClient.stub(:new, ->(*args) { raise GeminiClient::ConfigurationError.new("Missing Google Cloud credentials") }) do
      artist_draft = ArtistDraft.new(email_address: "config_error@test.com")
      result = artist_draft.extract_from_email_data(subject: "Configuration Error", text_body: "Should trigger a config error")

      assert_not result, "extract_from_email_data should return false on ConfigurationError"
      assert artist_draft.errors.added?(:base, :gemini_configuration_error), "Should add a :gemini_configuration_error to base"
      assert_not artist_draft.save, "Artist draft should not save on configuration error"
    end
  end

  test "artist_draft can attach images from base64" do
    draft = artist_drafts(:monet)
    decoded_content = Base64.decode64(base64_image_content)

    draft.artworks.attach(
      io: StringIO.new(decoded_content),
      filename: "test_image.png",
      content_type: "image/jpeg"
    )

    assert_equal 1, draft.artworks.count
    assert_equal "test_image.png", draft.artworks.first.filename.to_s
    assert_equal "image/jpeg", draft.artworks.first.content_type
    assert_equal decoded_content.bytesize, draft.artworks.first.byte_size
  end

  test "ensure_minimum_artworks adds default images on create if count is less than 5" do
    assert Dir.glob(Rails.root.join("public", "default_artworks", "*")).any?,
           "Ensure you have default images in public/default_artworks/ for this test"

    draft = ArtistDraft.create!(
      first_name: "Joe",
      last_name: "Artist",
      email_address: "joeartist@example.com",
      introduction: true
    )

    draft.reload

    assert_equal 5, draft.artworks.count, "Should have 5 default images after creation"
    draft.artworks.each do |artwork|
      assert artwork.persisted?, "Default image should be persisted"
      assert artwork.image?, "Default image should be an image type"
    end
  end

  test "ensure_minimum_artworks does not add default images if count is already 5 or more" do
    draft = artist_drafts(:dali)
    5.times do |i|
      draft.artworks.attach(
        io: StringIO.new(Base64.decode64(base64_image_content)),
        filename: "full_image_#{i}.png",
        content_type: "image/jpeg"
      )
    end
    assert_equal 5, draft.artworks.count

    # Update the draft
    draft.update!(first_name: "Already Full Artist")

    assert_equal 5, draft.artworks.count, "Should still have 5 images"
  end

  private

  def gemini_response
    JSON.parse(file_fixture("gemini_structured_response.json").read)
  end

  def gemini_response_not_intro
    JSON.parse(file_fixture("gemini_structured_response_not_intro.json").read)
  end

  def json_payload
    flunk unless File.exist?("test/fixtures/files/postmark_inbound_email_artist_draft_blobs.json")
    JSON.parse(file_fixture("postmark_inbound_email_artist_draft_blobs.json").read)
  end

  def base64_image_content
    pm_hash = json_payload
    pm_hash["Attachments"]&.first["Content"]
  end

  def normal_email
    <<~NORMAL_EMAIL
      Hi there,

      I'm Claude Monet - a painter, deeply fascinated by the ever-shifting dance
      of light and its fleeting impressions upon the naturla world.  I find my
      truest expression in capturing the ephemeral qualities of a landscape, a
      water lily pond, or the misty atmosphere of a morning. My brush strives to
      convey not merely what is seen, but what is felt - the very sensation of a
      moment.  A friend mentioned your platform and I thought I'd reach out

      I'm curious to learn more it looks like a really interesting space for
      connecting artists and clients in a more personal way, allowing for shared
      pursuit of beauty beyond the confines of traditional exhibitions.

      I’ve attached a few recent pieces that I believe exemplify this pursuit.
      Let me know if it’s worth setting up a page or profile, or if there’s
      anything else I should know. I believe a connection with discerning
      patrons could foster remarkable new endeavors.

      Best, Claude
    NORMAL_EMAIL
  end
end
