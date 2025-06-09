require "test_helper"

class GeminiClientTest < ActionDispatch::IntegrationTest
  test "extracts text from response" do
    fake_client = FakeGeminiClient.new(text: "Forty-two!")
    client = GeminiClient.new(api_client: fake_client, project_id: "test")

    result = client.generate(prompt: "What is the meaning of life the universe and everything?")
    assert_equal "Forty-two!", result
  end

  test "handles structured output" do
    fake_client = FakeGeminiClient.new(structured_data: { answer: "Forty-two" })
    client = GeminiClient.new(api_client: fake_client, project_id: "test")

    response = client.generate(
      prompt: "What is the meaning of life the universe and everything?",
      schema_name: "answer_finding",
      schema_description: "Correct structure for giving an answer",
      schema_properties: {
        answer: { type: "STRING" }
      }
    )
    assert_equal "Forty-two", response.dig("answer")
  end
end
