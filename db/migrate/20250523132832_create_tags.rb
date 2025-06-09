class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.integer :tag_type, null: false

      t.timestamps
    end

    add_index :tags, [ :name, :tag_type ], unique: true
  end
end
