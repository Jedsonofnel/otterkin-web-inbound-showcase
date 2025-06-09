class RemoveUserFromSubscriber < ActiveRecord::Migration[8.0]
  def change
    remove_column :subscribers, :user, :references
  end
end
