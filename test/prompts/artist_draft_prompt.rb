require "test_helper"

class ArtistDraftPrompt < ActionDispatch::IntegrationTest
  setup do
    @client = GeminiClient.new
  end

  test "long introduction returns successful response" do
    prompt = render_prompt("Hi from Claude", normal_email)
    response = @client.generate(**fields(prompt))

    puts JSON.pretty_generate(response)

    # Save to file if you want
    File.write("test/fixtures/files/gemini_structured_response.json", JSON.pretty_generate(response))

    assert response.is_a?(Hash)
    assert response["introduction"]
  end

  test "sparse introduction returns successful response" do
    prompt = render_prompt "Hi from Alex", sparse_email
    response = @client.generate(**fields(prompt))
    puts JSON.pretty_generate(response)

    assert response["introduction"]
  end

  test "super sparse introduction returns successful response" do
    prompt = render_prompt "Hi", super_sparse_email
    response = @client.generate(**fields(prompt))
    puts JSON.pretty_generate(response)

    assert response["introduction"]
  end

  test "spam email does not return as an introduction" do
    prompt = render_prompt "EXCITING BUSINESS OPPORTUNITY", spam_email
    response = @client.generate(**fields(prompt))
    puts JSON.pretty_generate(response)

    # For other testing
    File.write("test/fixtures/files/gemini_structured_response_not_intro.json", JSON.pretty_generate(response))

    assert_not response["introduction"]
  end

  test "query email does not return as an introduction" do
    prompt = render_prompt "Order #12345", query_email
    response = @client.generate(**fields(prompt))
    puts JSON.pretty_generate(response)

    assert_not response["introduction"]
  end

  private

  def fields(prompt)
    {
      prompt: prompt,
      schema_name: "extract_artist_draft",
      schema_description: "Extract or come up with required information for prospective artist's profile page.",
      schema_required: [ "introduction", "first_name", "last_name", "biography", "location", "tags", "questions", "commission_types" ],
      schema_properties: GeminiSchemas::ARTIST_DRAFT
    }
  end

  def render_prompt(subject, text_body)
    <<~PROMPT
      #{ArtistDraft::PROMPT_PREAMBLE}

      Subject: #{subject}

      #{text_body}
    PROMPT
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

  def super_sparse_email
    "Hi, I'm an artist and I'd like to join your platform"
  end

  def sparse_email
    <<~SPARSE_EMAIL
      Hello,

      My name is Alex Chen, and I'm a digital illustrator based in Warwick. I
      specialize in character design and fantasy art. I saw your platform and
      was really impressed with the artists you feature. I'd love to learn more
      about how I can be a part of your community.

      Thanks, Alex
    SPARSE_EMAIL
  end

  def spam_email
    <<~SPAM_EMAIL
      Dear Sir/Madam,

      I hope this email finds you well. I am writing to you today with an urgent
      business proposal that I believe will be of great mutual benefit. We have
      identified a lucrative investment opportunity in the renewable energy
      sector in your region. Your assistance is required to facilitate a secure
      transfer of funds, for which you will receive a significant commission.
      Please reply to this email for more details and to discuss the next steps.

      Sincerely, Mr. John Smith Investment Consultant
    SPAM_EMAIL
  end

  def query_email
    <<~QUERY_EMAIL
      Hi there,

      I recently placed an order (ID #12345) on your marketplace for a
      commission from artist Andrew. I haven't received an update on the
      progress of my commission in a week. Could you please check on the status
      for me and let me know when I can expect an update or completion?

      Thanks, Sarah Johnson"
    QUERY_EMAIL
  end
end
