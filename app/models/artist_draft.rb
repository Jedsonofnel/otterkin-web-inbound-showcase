class ArtistDraft < ApplicationRecord
  include Taggable
  include GeminiSchemas

  attr_accessor :introduction
  validate :must_be_an_introduction, on: :create

  # tokens
  generates_token_for :ownership

  has_many_attached :artworks
  after_create_commit :ensure_minimum_artworks

  validates :first_name, presence: true
  validates :last_name, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, presence: true, uniqueness: true, format: URI::MailTo::EMAIL_REGEXP

  def extract_from_email_data(text_body:, subject:, gemini_client: nil)
    gemini_client ||= GeminiClient.new

    response = fetch_gemini_data(gemini_client, text_body, subject)

    @introduction = response["introduction"]
    unless @introduction
      errors.add(:base, :not_an_introduction, message: "Gemini does not think the email is an introduction.")
      return false
    end

    load_gemini_response response.with_indifferent_access
    true
  rescue GeminiClient::ConfigurationError => e
    errors.add(:base, :gemini_configuration_error, message: e.message)
    false
  rescue GeminiClient::MalformedResponseError,
          GeminiClient::UnexpectedSchemaError,
          GeminiClient::EmptyStructuredResponseError => e
    Rails.logger.warn("Gemini parsing error for prompt: #{subject.inspect}, #{text_body.truncate(50).inspect}. Error: #{e.message}")
    errors.add(:base, :gemini_parsing_error, message: "Gemini response was unreadable or malformed.")
    false
  rescue GeminiClient::APIError => e
    errors.add(:base, :gemini_api_error, message: "Gemini API error: #{e.message}")
    false
  end

  def load_gemini_response(response)
    self.first_name = response[:first_name]
    self.last_name = response[:last_name]
    self.biography = response[:biography]
    self.location = response[:location]
    self.data = response[:tags]
    self.data["questions"] = response[:questions]
    self.data["commission_types"] = response[:commission_types]
    self
  end

  def mock_commission_types_for_display
    mock_types = (data["commission_types"] || []).map.with_index do |ct_data, i|
      MockCommissionType.new(ct_data, i)
    end

    mock_types.define_singleton_method(:minimum) do |attribute|
      valid_items = self.reject { |item| item.send(attribute).nil? }
      if valid_items.any?
        valid_items.map { |item| item.send(attribute) }.min
      else
        nil
      end
    end

    mock_types
  end

  private

  def fetch_gemini_data(gemini_client, text_body, subject)
    gemini_client.generate(
      prompt: build_prompt(text_body, subject),
      schema_name: "extract_artist_draft",
      schema_properties: GeminiSchemas::ARTIST_DRAFT,
      schema_description: "Extract or come up with required information for a draft of a prospective artist's profile page.",
      schema_required: [ "introduction", "first_name", "last_name", "biography", "location", "tags", "questions", "commission_types" ]
    )
  end

  def must_be_an_introduction
    unless introduction
      errors.add(:base, :not_an_introduction, message: "Email is not an artist introduction.")
    end
  end

  PROMPT_PREAMBLE = <<~PROMPT_PREAMBLE
    Generate artist draft data for a profile page based on the provided
    introductory email. If information is missing, create reasonable, relevant
    details. Only respond with the `extract_artist_draft` function call, even if
    it requires significant inference.
  PROMPT_PREAMBLE

  def build_prompt(email_body, subject)
    <<~PROMPT
      #{PROMPT_PREAMBLE}

      Subject: #{subject}

      #{email_body}
    PROMPT
  end

  def ensure_minimum_artworks
    missing_count = 5 - artworks.count
    return if missing_count <= 0

    artworks.reload
    add_random_default_artworks(missing_count)
  end

  def add_random_default_artworks(count)
    default_artwork_files = Dir.glob(Rails.root.join("public", "default_artworks", "*"))
    selected_files = default_artwork_files.sample(count)

    selected_files.each do |path|
      begin
        filename = File.basename(path)
        content_type = Marcel::MimeType.for(File.open(path), name: filename)

        # Attach the default image using Active Storage
        artworks.attach(
          io: File.open(path),
          filename: filename,
          content_type: content_type
        )
      rescue StandardError => e
        Rails.logger.error "Failed to attach default image #{filename}: #{e.message}"
      end
    end
  end
end
