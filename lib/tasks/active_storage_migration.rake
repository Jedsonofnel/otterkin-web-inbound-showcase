require "google/cloud/storage"
require "digest/md5"

namespace :active_storage do
  desc "Migrates local Active Storage files to Google Cloud Storage"
  task migrate_local_to_gcs: :environment do
    puts "Starting Active Storage local to GCS migration..."

    # Determine the bucket name dynamically
    deployment_environment = ENV.fetch("DEPLOYMENT_ENVIRONMENT", "prod")
    bucket_name = "rails_app_#{deployment_environment}_bucket"

    puts "Targeting bucket: #{bucket_name} for deployment environment: #{deployment_environment}"

    # Initialize GCS client using credentials configured for Rails
    project_id = Rails.application.credentials.dig(:google_cloud, :project_id)
    keyfile_content_string = Rails.application.credentials.dig(:google_cloud, :gcs_access_keyfile_content)

    if project_id.blank? || keyfile_content_string.blank?
      puts "Error: Google Cloud project_id or keyfile_content not found in Rails credentials. Please configure config/credentials.yml.enc"
      exit(1)
    end

    # Temporarily set GOOGLE_APPLICATION_CREDENTIALS for the Google Cloud Storage client
    original_gac = ENV["GOOGLE_APPLICATION_CREDENTIALS"]
    require "tempfile"
    temp_keyfile = nil

    begin
      temp_keyfile = Tempfile.new([ "gcs_keyfile", ".json" ])
      temp_keyfile.write(keyfile_content_string)
      temp_keyfile.rewind
      ENV["GOOGLE_APPLICATION_CREDENTIALS"] = temp_keyfile.path

      storage = Google::Cloud::Storage.new(project_id: project_id)
      bucket = storage.bucket bucket_name

      if bucket.nil?
        puts "Error: Bucket '#{bucket_name}' not found or inaccessible. Check your config/storage.yml and GCS permissions."
        exit(1)
      end

      total_blobs = ActiveStorage::Blob.count
      puts "Found #{total_blobs} blobs to process."

      # Iterate over blobs, uploading local files
      ActiveStorage::Blob.find_each.with_index do |blob, index|
        print "Processing blob #{index + 1}/#{total_blobs}: #{blob.filename} (key: #{blob.key})..."

        # This path assumes the default Active Storage DiskService structure
        local_path = Rails.root.join("storage", blob.key[0..1], blob.key[2..3], blob.key)

        if File.exist?(local_path)
          begin
            # Check if the file already exists in GCS to avoid re-uploading
            gcs_file = bucket.file(blob.key)
            if gcs_file && gcs_file.exists? && gcs_file.md5 == blob.checksum
              puts " Already exists in GCS. Skipping."
              next # Skip to next blob
            end

            # Upload the file to GCS
            File.open(local_path, "rb") do |file|
              bucket.create_file(file, blob.key,
                                 content_type: blob.content_type,
                                 md5: blob.checksum)
            end
            puts " Uploaded to GCS."
          rescue Google::Cloud::Error => e
            puts " Error uploading blob #{blob.key}: #{e.message}"
            # Optionally, log to an error file or track failed blobs
          rescue StandardError => e
            puts " Unexpected error for blob #{blob.key}: #{e.message}"
            # Optionally, log to an error file or track failed blobs
          end
        else
          puts " Local file not found at #{local_path}. Skipping blob #{blob.key}."
          # This can happen if a blob record exists but the file was manually deleted locally
        end
      end

      puts "Active Storage local to GCS migration complete."
    rescue => e
      puts "Fatal error during migration: #{e.message}"
      puts e.backtrace.join("\n")
      exit(1)
    ensure
      # Clean up the temporary file and restore original env var
      if temp_keyfile
        temp_keyfile.close
        temp_keyfile.unlink
      end
      ENV["GOOGLE_APPLICATION_CREDENTIALS"] = original_gac # Restore original GAC
    end
  end
end
