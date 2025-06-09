require "google/cloud/ai_platform/v1"
require "json"

class GeminiClient
  class ConfigurationError < StandardError; end
  class APIError < StandardError; end
  class MalformedResponseError < APIError; end
  class UnexpectedSchemaError < APIError; end
  class EmptyStructuredResponseError < APIError; end

  attr_reader :api_client

  def initialize(project_id: nil, location: "europe-west2", model_id: "gemini-2.0-flash", api_client: nil)
    @project_id = project_id || ENV["GOOGLE_CLOUD_PROJECT"] ||
                  Rails.application.credentials.dig(:google_cloud, :project_id) ||
                  raise(ArgumentError, "project_id required")
    @location = location || ENV["GOOGLE_CLOUD_LOCATION"]
    @model_id = model_id
    @api_client = api_client || Google::Cloud::AIPlatform.prediction_service

  rescue StandardError => e
    raise ConfigurationError, "Gemini client initialization failed unexpectedly: #{e.message}"
  end

  def generate(prompt:, schema_name: nil, schema_properties: nil,
               schema_description: nil, schema_required: [])
    request_params = {
      model: model_path,
      contents: [ { role: "user", parts: [ { text: prompt } ] } ]
    }

    # optionally add structure
    if schema_name && schema_properties
      request_params[:tools] = build_tools(schema_name, schema_description, schema_properties, schema_required)
    end

    response = api_client.generate_content(**request_params)

    schema_name ? extract_structured_response(response, schema_name, prompt) :
                  extract_text_response(response)
  rescue => e
    Rails.logger.error("Gemini API error: #{e.message}, Request: #{request_params.inspect}")
    raise APIError.new(e.message)
  end

  private

  def model_path
    "projects/#{@project_id}/locations/#{@location}/publishers/google/models/#{@model_id}"
  end

  def build_tools(name, description, properties, required)
    [ {
      function_declarations: [
        {
          name: name,
          description: description,
          parameters: {
            type: "OBJECT",
            properties: properties,
            required: required
          }
        }
      ]
    } ]
  end

  def extract_text_response(response)
    response.candidates&.first&.content&.parts&.first&.text
  end

  def extract_structured_response(response, expected_name, prompt)
    part = response.candidates&.first&.content&.parts&.first

    raise MalformedResponseError, "No response parts" unless part

    unless part.function_call.present?
      Rails.logger.warn("Gemini returned text instead of structured output for prompt: #{prompt.truncate(50)}. Text: #{part.text.to_s.truncate(50)}")
      raise MalformedResponseError, "Gemini returned text instead of structured output."
    end

    call = part.function_call

    raise UnexpectedSchemaError, "Expected schema '#{expected_name}' but got '#{call.name}'" unless call.name == expected_name

    raise EmptyStructuredResponseError, "Structured response is empty for schema: #{expected_name}" unless call.args.present? && call.args.to_h.any?

    call.args.to_h
  rescue NoMethodError => e
    raise MalformedResponseError, "Malformed Gemini response structure: #{e.message}"
  end
end
