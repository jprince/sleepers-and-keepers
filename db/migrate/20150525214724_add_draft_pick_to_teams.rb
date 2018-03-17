class AddDraftPickToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :draft_pick, :integer
  end
end
