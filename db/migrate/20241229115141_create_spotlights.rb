class CreateSpotlights < ActiveRecord::Migration[8.0]
  def change
    create_table :spotlights do |t|
      t.references :article, null: false, foreign_key: true
      t.boolean :in_rotation, default: false

      t.timestamps
    end
  end
end
