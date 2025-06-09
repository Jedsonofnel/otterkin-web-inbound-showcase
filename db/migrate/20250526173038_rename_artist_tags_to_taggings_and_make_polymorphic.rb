class RenameArtistTagsToTaggingsAndMakePolymorphic < ActiveRecord::Migration[8.0]
  def change
    # rename the table
    rename_table :artist_tags, :taggings

    # make polymorphic
    rename_column :taggings, :artist_id, :taggable_id

    # add taggable_type column (for model name)
    add_column :taggings, :taggable_type, :string, null: false, default: 'Artist'

    add_index :taggings, [ :taggable_type, :taggable_id ]
  end
end
