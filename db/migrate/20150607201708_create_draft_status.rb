class CreateDraftStatus < ActiveRecord::Migration
  def change
    create_table :draft_statuses do |t|
      t.string :description

      t.timestamps
    end
  end
end
