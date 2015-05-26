class AddDraftPickToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :draft_pick, :integer
  end
end
