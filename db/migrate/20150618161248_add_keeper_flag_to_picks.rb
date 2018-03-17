class AddKeeperFlagToPicks < ActiveRecord::Migration[5.0]
  def change
    add_column :picks, :keeper, :boolean, default: false, null: false
  end
end
