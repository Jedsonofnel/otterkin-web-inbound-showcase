class FixCommissionTypesForeignKeyConstraint < ActiveRecord::Migration[8.0]
  def change
    change_column_null :commission_types, :artist_id, true
  end
end
