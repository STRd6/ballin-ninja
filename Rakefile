require 'sinatra/activerecord/rake'

namespace :db do
  task :connect do
    require "./config/environments"

    DB.connect
  end

  task :migrate => :connect
end

task :dump_db do
  sh "pg_dump -Fc --no-acl --no-owner -h localhost git_info > mydb.dump"
end
