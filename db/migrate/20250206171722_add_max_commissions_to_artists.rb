class AddMaxCommissionsToArtists < ActiveRecord::Migration[8.0]
  def change
    add_column :artists, :max_commissions, :integer, default: 5
  end
end
