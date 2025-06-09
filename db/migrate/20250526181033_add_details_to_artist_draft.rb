class AddDetailsToArtistDraft < ActiveRecord::Migration[8.0]
  def change
    add_column :artist_drafts, :biography, :text
    add_column :artist_drafts, :location, :string
    remove_index :artist_drafts, :artist_id
    remove_column :artist_drafts, :artist_id
  end
end
