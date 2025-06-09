class SubscribersCleanupJob < ApplicationJob
  queue_as :default

  def perform
    suppressions = client.dump_suppressions("outbound")

    all_emails = suppressions.map { |s| s[:email_address] }.compact.uniq
    normalized_all_emails = all_emails.map(&:strip).map(&:downcase).uniq

    deleted_count = Subscriber.where("LOWER(email_address) IN (?)", normalized_all_emails.map(&:downcase)).delete_all

    logger.info "[SubscribersCleanupJob] Deleted #{deleted_count} subscriber(s) from #{all_emails.size} suppressed emails"

    non_spam_emails = suppressions
      .reject { |s| s[:suppression_reason] == "SpamComplaint" }
      .map { |s| s[:email_address] }
      .compact
      .uniq

    non_spam_emails.each_slice(50) do |batch|
      logger.info "[SubscribersCleanupJob] Deleting suppression batch of #{batch.size} from Postmark"
      client.delete_suppressions("outbound", batch)
    end
  end

  private

  def client
    Postmark::ApiClient.new(
      Rails.application.credentials.dig(:postmark_api_token)
    )
  end
end
