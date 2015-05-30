class AddPositionsToSports < ActiveRecord::Migration
  def change
    add_column :sports, :positions, :text, array: true, default: []
  end
end
