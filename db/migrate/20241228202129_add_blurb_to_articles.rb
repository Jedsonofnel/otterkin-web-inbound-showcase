class AddBlurbToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :blurb, :text
  end
end
