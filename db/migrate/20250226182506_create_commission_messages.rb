class CreateCommissionMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :commission_messages do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :commission, null: false, foreign_key: true

      t.timestamps
    end
  end
end
