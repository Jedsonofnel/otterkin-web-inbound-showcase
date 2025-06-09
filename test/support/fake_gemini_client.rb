class FakeGeminiClient
  attr_accessor :response_type, :text, :structured_data, :raise_error

  def initialize(text: nil, structured_data: nil, raise_error: nil)
    @text = text
    @structured_data = structured_data
    @raise_error = raise_error
  end

  def generate_content(model:, contents:, tools: [])
    raise raise_error if raise_error

    function_name = tools&.first&.dig(:function_declarations)&.first&.dig(:name)

    if structured_data
      build_structured_response(structured_data, function_name)
    else
      build_text_response(text || "default fake response")
    end
  end

  private

  def build_text_response(text)
    part = Google::Cloud::AIPlatform::V1::Part.new(text: text)
    content = Google::Cloud::AIPlatform::V1::Content.new(parts: [ part ])
    candidate = Google::Cloud::AIPlatform::V1::Candidate.new(content: content)
    Google::Cloud::AIPlatform::V1::GenerateContentResponse.new(candidates: [ candidate ])
  end

  def build_structured_response(data, function_name)
    struct = Google::Protobuf::Struct.decode_json(data.to_json)
    function_call = Google::Cloud::AIPlatform::V1::FunctionCall.new(
      name: function_name,
      args: struct
    )
    part = Google::Cloud::AIPlatform::V1::Part.new(
      function_call: function_call
    )
    content = Google::Cloud::AIPlatform::V1::Content.new(parts: [ part ])
    candidate = Google::Cloud::AIPlatform::V1::Candidate.new(content: content)
    Google::Cloud::AIPlatform::V1::GenerateContentResponse.new(candidates: [ candidate ])
  end
end
