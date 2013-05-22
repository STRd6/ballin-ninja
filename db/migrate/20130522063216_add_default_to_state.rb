class AddDefaultToState < ActiveRecord::Migration
  def change
    change_column :repos, :state, :string, :limit => 16, :null => false, :default => ""
  end
end
