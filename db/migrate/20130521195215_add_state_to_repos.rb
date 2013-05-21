class AddStateToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :state, :string, :null => false, :default => "", :limit => 16

    add_index :repos, :state
  end
end
