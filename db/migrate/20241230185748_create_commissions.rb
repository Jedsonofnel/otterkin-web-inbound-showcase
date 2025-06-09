class CreateCommissions < ActiveRecord::Migration[8.0]
  def change
    create_table :commissions do |t|
      t.references :user, foreign_key: true
      t.references :artist, foreign_key: true
      t.integer :stage, default: 0
      t.text :description
      t.float :price

      t.timestamps
    end
  end
end
