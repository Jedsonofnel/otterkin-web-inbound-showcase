class CreateArtistTags < ActiveRecord::Migration[8.0]
  def change
    create_table :artist_tags do |t|
      t.references :artist, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end
  end
end
