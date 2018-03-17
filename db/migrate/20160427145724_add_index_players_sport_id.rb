class AddIndexPlayersSportId < ActiveRecord::Migration[5.0][5.0]
  def change
    add_index :players, :sport_id
  end
end
