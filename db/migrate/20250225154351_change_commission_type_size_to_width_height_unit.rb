class ChangeCommissionTypeSizeToWidthHeightUnit < ActiveRecord::Migration[8.0]
  def change
    remove_column :commission_types, :size, :string

    add_column :commission_types, :width, :decimal, precision: 8, scale: 2
    add_column :commission_types, :height, :decimal, precision: 8, scale: 2
    add_column :commission_types, :unit, :integer, default: 0
  end
end
