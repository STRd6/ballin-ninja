class CreateApiTokens < ActiveRecord::Migration
  def change
    create_table :api_tokens do |t|
      t.string :token, :null => false

      t.timestamps :null => false
    end

    add_index :api_tokens, :token, :unique => true
  end
end
