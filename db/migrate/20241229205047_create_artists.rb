class CreateArtists < ActiveRecord::Migration[8.0]
  def change
    create_table :artists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :instagram_handle
      t.text :biography
      t.boolean :approved, default: false

      t.timestamps
    end
  end
end
