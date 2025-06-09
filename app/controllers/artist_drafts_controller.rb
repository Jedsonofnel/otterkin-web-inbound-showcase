class ArtistDraftsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_artist_draft, except: [ :not_found ]

  def show
  end

  def convert
  end

  def destroy
    if @token.nil? && !admin?
      return redirect_to root_path, alert: "You do not have permission to do that, dave."
    end

    @artist_draft.destroy!
    redirect_to root_path, notice: "Successfully deleted your artist draft."
  end

  def not_found
  end

  private

  def set_artist_draft
    if @artist_draft = ArtistDraft.find_by_token_for(:ownership, params[:token])
      @token = params[:token]
    else
      @artist_draft = ArtistDraft.find_by(id: params[:id])
    end

    redirect_to(not_found_artist_drafts_path) and return unless @artist_draft
  end
end
