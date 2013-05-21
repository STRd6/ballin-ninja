class AddStateToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :state, :string, :limit => 16

    add_index :repos, :state
  end
end
