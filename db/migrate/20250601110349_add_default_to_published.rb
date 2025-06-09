class AddDefaultToPublished < ActiveRecord::Migration[8.0]
  def change
    change_column_default :articles, :published, false
  end
end
