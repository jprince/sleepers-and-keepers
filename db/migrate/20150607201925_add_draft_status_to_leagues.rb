class AddDraftStatusToLeagues < ActiveRecord::Migration[5.0]
  def change
    add_column :leagues, :draft_status_id, :integer
  end
end
