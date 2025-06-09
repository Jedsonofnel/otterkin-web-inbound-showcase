class CreateCommissionDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :commission_details do |t|
      t.references :commission, null: false, foreign_key: true
      t.text :subject
      t.text :style
      t.text :colour_palette
      t.text :story
      t.text :display_location
      t.text :brief
      t.text :extra_detail

      t.timestamps
    end
  end
end
