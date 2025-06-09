class AddArtistDetailsToSubscriber < ActiveRecord::Migration[8.0]
  def change
    add_column :subscribers, :artist, :boolean, default: false
    add_column :subscribers, :instagram_handle, :string
    add_column :subscribers, :introduction, :text
  end
end
