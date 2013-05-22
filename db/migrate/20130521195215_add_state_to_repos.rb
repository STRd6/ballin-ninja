class AddStateToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :state, :string, :limit => 16, :null => false, :default => ""

    add_index :repos, :state
  end
end
