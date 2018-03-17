class AddNameToUsers < ActiveRecord::Migration[5.0]
  def self.up
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    # The below lines are necessary because sqlLite3 does not allow a not null constraint to
    # be added to a table after its initial creation. For details see:
    # http://stackoverflow.com/questions/3170634/how-to-solve-cannot-add-a-not-null-column-with-default-value-null-in-sqlite3
    change_column :users, :first_name, :string, null: false
    change_column :users, :last_name, :string, null: false
  end

  def self.down
    remove_column :profiles, :last_name
    remove_column :profiles, :first_name
  end
end
