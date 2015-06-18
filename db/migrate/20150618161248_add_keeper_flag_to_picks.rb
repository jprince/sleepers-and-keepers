class AddKeeperFlagToPicks < ActiveRecord::Migration
  def change
    add_column :picks, :keeper, :boolean, default: false, null: false
  end
end
