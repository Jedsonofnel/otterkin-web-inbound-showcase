class AddDesignationToArticles < ActiveRecord::Migration[8.0]
  def change
    add_column :articles, :designation, :integer, default: 0
  end
end
