class AddArtistToArtwork < ActiveRecord::Migration[8.0]
  def change
    add_reference :artworks, :artist, null: false, foreign_key: true
  end
end
