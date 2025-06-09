require "test_helper"
require "json"

class ArtistDraftsControllerTest < ActionDispatch::IntegrationTest
  setup do
    setup_monet_response_data
    @artist_draft = artist_drafts(:monet)

    # these should all be publicly accessible
    sign_out
  end

  test "should get show" do
    get artist_draft_url(@artist_draft)
    assert_response :success
  end

  test "should get convert" do
    get convert_artist_draft_url(@artist_draft)
    assert_response :success
  end

  test "destroy works with token" do
    token = @artist_draft.generate_token_for(:ownership)
    assert_difference [ "ArtistDraft.count" ], -1 do
      delete artist_draft_url(@artist_draft, token: token)
    end
    assert_response :redirect
  end

  test "destroy does not work without a token" do
    assert_no_difference [ "ArtistDraft.count" ] do
      delete artist_draft_url(@artist_draft)
    end
    assert_response :redirect
  end

  test "destroy works without a token if admin" do
    sign_in users(:blanco)
    assert_difference [ "ArtistDraft.count" ], -1 do
      delete artist_draft_url(@artist_draft)
    end
    assert_response :redirect
  end

  test "should get not found page" do
    get not_found_artist_drafts_url
    assert_response :success
  end

  test "should redirect to not found if id is invalid on show" do
    id = 15062004
    assert_not_equal artist_drafts(:monet), id
    assert_not_equal artist_drafts(:dali), id

    get artist_draft_url(id)
    assert_redirected_to not_found_artist_drafts_url
  end

  test "should redirect to not found if id is invalid on convert" do
    id = 15062004
    assert_not_equal artist_drafts(:monet), id
    assert_not_equal artist_drafts(:dali), id

    get convert_artist_draft_url(id)
    assert_redirected_to not_found_artist_drafts_url
  end

  private

  def setup_monet_response_data
    data = JSON.parse(file_fixture("gemini_structured_response.json").read)
    data = data.with_indifferent_access
    artist_drafts(:monet).load_gemini_response(data)
    artist_drafts(:monet).save
  end
end
