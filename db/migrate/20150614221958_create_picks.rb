class CreatePicks < ActiveRecord::Migration[5.0]
  def change
    create_table :picks do |t|
      t.integer :overall_pick, null: false
      t.integer :player_id
      t.integer :round, null: false
      t.integer :round_pick, null: false
      t.integer :team_id

      t.timestamps
    end
  end
end
