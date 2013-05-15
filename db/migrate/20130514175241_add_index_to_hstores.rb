class AddIndexToHstores < ActiveRecord::Migration
  def change
    add_hstore_index :people, :data
    add_hstore_index :people, :response

    add_hstore_index :repos, :data
    add_hstore_index :repos, :response
  end
end
