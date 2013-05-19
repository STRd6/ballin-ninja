class AddErrorToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :error, :string
  end
end
