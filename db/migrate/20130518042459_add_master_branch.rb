class AddMasterBranch < ActiveRecord::Migration
  def change
    add_column :repos, :master_branch, :string
    add_index :repos, :master_branch
  end
end
