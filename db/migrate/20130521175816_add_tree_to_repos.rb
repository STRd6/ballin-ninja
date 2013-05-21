class AddTreeToRepos < ActiveRecord::Migration
  def up
    add_column :repos, :tree, :string_array
  end

  def down
    remove_column :repos, :tree
  end
end
