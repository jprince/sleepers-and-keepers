class AddIndexTeamsLeagueId < ActiveRecord::Migration[5.0][5.0]
  def change
    add_index :teams, :league_id
  end
end
