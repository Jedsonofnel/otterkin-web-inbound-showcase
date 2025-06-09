class AddActiveToArtists < ActiveRecord::Migration[8.0]
  def change
    add_column :artists, :active, :boolean, default: false
  end
end
