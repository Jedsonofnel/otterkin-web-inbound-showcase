class AddUserToSubscribers < ActiveRecord::Migration[8.0]
  def change
    add_reference :subscribers, :user, foreign_key: true
  end
end
