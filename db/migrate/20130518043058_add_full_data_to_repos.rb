class AddFullDataToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :full_data, :hstore
  end
end
