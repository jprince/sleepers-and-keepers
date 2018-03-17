class AddIndexesToPicks < ActiveRecord::Migration[5.0][5.0]
  def change
    add_index :picks, :keeper
    add_index :picks, :player_id
    add_index :picks, :team_id
  end
end
