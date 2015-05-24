class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :short_name, null: false, limit: 10
      t.integer :user_id, null: false
      t.integer :league_id, null: false

      t.timestamps
    end
  end
end
