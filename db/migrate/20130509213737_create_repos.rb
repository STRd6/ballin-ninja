class CreateRepos < ActiveRecord::Migration
  def up
    create_table :repos do |t|
      t.hstore :response
      t.hstore :data

      t.timestamps :null => false
    end

    create_table :people do |t|
      t.hstore :response
      t.hstore :data

      t.timestamps :null => false
    end
  end

  def down
    drop_table :people
    drop_table :repos
  end
end
