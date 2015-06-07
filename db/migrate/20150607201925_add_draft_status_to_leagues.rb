class AddDraftStatusToLeagues < ActiveRecord::Migration
  def change
    add_column :leagues, :draft_status_id, :integer
  end
end
