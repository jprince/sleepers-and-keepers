class AddIndexesToLeagues < ActiveRecord::Migration[5.0][5.0]
  def change
    add_index :leagues, :draft_status_id
    add_index :leagues, :sport_id
    add_index :leagues, :user_id
  end
end
