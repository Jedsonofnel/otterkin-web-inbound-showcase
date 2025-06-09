class AddCommissionTypeToCommissions < ActiveRecord::Migration[8.0]
  def change
    add_reference :commissions, :commission_type, foreign_key: { to_table: :commission_types }
  end
end
