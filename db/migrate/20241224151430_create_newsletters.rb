class CreateNewsletters < ActiveRecord::Migration[8.0]
  def change
    create_table :newsletters do |t|
      t.references :article, null: false, foreign_key: true
      t.datetime :last_sent, default: nil
      t.integer :sent_to, default: 0
      t.integer :visited, default: 0

      t.timestamps
    end
  end
end
