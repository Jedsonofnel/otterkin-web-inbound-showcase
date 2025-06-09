class CreateArtistDrafts < ActiveRecord::Migration[8.0]
  def change
    create_table :artist_drafts do |t|
      t.string :email_address
      t.string :first_name
      t.string :last_name
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
