class CreateArtistCommissionTypes < ActiveRecord::Migration[8.0]
  def change
    create_table :commission_types do |t|
      t.string :size
      t.string :subject
      t.string :medium
      t.decimal :price
      t.references :artist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
