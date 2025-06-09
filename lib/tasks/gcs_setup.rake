require "google/cloud/storage"

namespace :gcs do
  desc "Configures CORS policies for the Active Storage bucket"
  task setup_cors: :environment do
    puts "Starting GCS CORS configuration..."

    # Ensure Active Storage is configured for GCS
    unless Rails.application.config.active_storage.service == :google
      puts "Error: Active Storage production service is not set to :google. Cannot configure CORS."
      exit(1)
    end

    deployment_environment = ENV.fetch("DEPLOYMENT_ENVIRONMENT", "prod")
    bucket_name = "rails_app_#{deployment_environment}_bucket"

    storage = Google::Cloud::Storage.new(
      project_id: Rails.application.credentials.dig(:google_cloud, :project_id),
      credentials: JSON.parse(Rails.application.credentials.dig(:google_cloud, :gcs_access_keyfile_content))
    )
    bucket = storage.bucket bucket_name

    if bucket.nil?
      puts "Error: GCS bucket '#{bucket_name}' not found or inaccessible. Check your config/storage.yml and GCS permissions."
      exit(1)
    end

    # Define your CORS rules
    case ENV.fetch("DEPLOYMENT_ENVIRONMENT", "prod")
    when "prod"
      allowed_origins = [ "https://otterkin.co.uk", "http://otterkin.co.uk" ]
    when "dev"
      allowed_origins = [ "https://dev.otterkin.co.uk", "http://dev.otterkin.co.uk" ]
    else
      allowed_origins = [ "*" ] # Fallback, use with caution
    end

    # You might also want to dynamically set headers/methods based on your needs
    allowed_methods = [ "PUT", "POST", "GET", "HEAD" ] # GET/HEAD might be useful if you're serving content publicly through GCS
    allowed_headers = [ "Content-Type", "x-goog-resumable", "Origin", "Content-MD5", "Content-Disposition" ] # Ensure all necessary headers are allowed
    max_age_seconds = 3600

    bucket.cors do |c|
      c.add_rule allowed_origins,
                 allowed_methods,
                 headers: allowed_headers,
                 max_age: max_age_seconds
    end

    puts "Set CORS policies for bucket '#{bucket_name}' with origins: #{allowed_origins.join(', ')}"
  rescue StandardError => e
    puts "Failed to set GCS CORS policies: #{e.message}"
    puts e.backtrace.join("\n")
    exit(1) # Exit with a non-zero status to indicate failure
  end
end
