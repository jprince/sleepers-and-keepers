class CreateLeagues < ActiveRecord::Migration
  def change
    create_table(:leagues) do |t|
      t.string :name, null: false
      t.integer :sport_id, null: false
      t.string :password, null: false
      t.integer :size, null: false
      t.integer :rounds, null: false
      t.integer :user_id, null: false

      t.timestamps
    end
  end
end
