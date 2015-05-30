class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :first_name
      t.string :last_name, null: false
      t.string :position, null: false
      t.string :team, null: false
      t.text :injury
      t.text :headline
      t.text :photo_url
      t.string :sport_id, null: false
      t.string :pro_status
      t.string :orig_id, null: false

      t.timestamps
    end
  end
end
