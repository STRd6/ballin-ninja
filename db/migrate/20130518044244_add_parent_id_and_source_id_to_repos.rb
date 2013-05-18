class AddParentIdAndSourceIdToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :parent_id, :integer
    add_column :repos, :source_id, :integer
  end
end
