class AddActiveToApiTokens < ActiveRecord::Migration
  def change
    add_column :api_tokens, :active, :boolean, :default => true, :null => false
  end
end
