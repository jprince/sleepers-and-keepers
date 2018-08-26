class AddIndexToPickOverallPick < ActiveRecord::Migration[5.1]
  def change
    add_index :picks, :overall_pick
  end
end
