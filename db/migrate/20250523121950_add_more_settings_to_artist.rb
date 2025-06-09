class AddMoreSettingsToArtist < ActiveRecord::Migration[8.0]
  def change
    add_column :artists, :location, :text
    add_column :artists, :in_person, :boolean
    add_column :artists, :commission_time, :integer
  end
end
