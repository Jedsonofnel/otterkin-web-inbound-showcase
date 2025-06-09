class CreateUserSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :user_settings do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.boolean :subscribed

      t.timestamps
    end
  end
end
