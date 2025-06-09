class ChangeArtistActiveToStatus < ActiveRecord::Migration[8.0]
  def change
    change_table :artists do |t|
      t.rename :active, :status
      t.change :status, :integer
    end
  end
end
