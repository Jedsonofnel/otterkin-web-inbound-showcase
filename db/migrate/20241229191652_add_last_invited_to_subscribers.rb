class AddLastInvitedToSubscribers < ActiveRecord::Migration[8.0]
  def change
    add_column :subscribers, :last_invited, :datetime
  end
end
