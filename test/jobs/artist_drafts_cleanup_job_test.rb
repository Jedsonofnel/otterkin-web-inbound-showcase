require "test_helper"

class ArtistDraftsCleanupJobTest < ActiveJob::TestCase
  test "deletes artist drafts older than 30 days" do
    dali = artist_drafts(:dali)
    assert dali.created_at <= 30.days.ago

    monet = artist_drafts(:monet)
    assert_not monet.created_at <= 30.days.ago

    assert_difference [ "ArtistDraft.count" ], -1 do
      ArtistDraftsCleanupJob.perform_now
    end

    assert ArtistDraft.exists?(monet.id)
    assert_not ArtistDraft.exists?(dali.id)
  end
end
