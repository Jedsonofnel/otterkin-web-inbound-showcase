class ArtistDraftsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ArtistDraft.where("created_at <= ?", 30.days.ago).destroy_all
  end
end
