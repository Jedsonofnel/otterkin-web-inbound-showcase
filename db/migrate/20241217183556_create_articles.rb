class CreateArticles < ActiveRecord::Migration[8.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.boolean :published
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps
    end
  end
end
