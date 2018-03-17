class CreateSports < ActiveRecord::Migration[5.0]
  def change
    create_table(:sports) do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
