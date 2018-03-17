class AddPositionsToSports < ActiveRecord::Migration[5.0]
  def change
    add_column :sports, :positions, :text, array: true, default: []
  end
end
