require 'sinatra/activerecord/rake'

namespace :db do
  task :connect do
    require "./config/environments"

    DB.connect
  end

  task :rollback => :connect
  task :migrate => :connect
end

task :dump_db do
  sh "pg_dump -Fc --no-acl --no-owner -h localhost git_info > mydb.dump"
end

task :default => :deploy

desc "Ship it!"
task :deploy do
  sh "bundle exec foreman start -f ./deploy.Procfile"
end

desc "Log it!"
task :logs do
  sh "foreman start -f ./logs.Procfile"
end

namespace :heroku do
  task :restart do
    sh "heroku restart --app pure-scrubland-1990"
    sh "heroku restart --app polar-mountain-9297"
  end

  task :migrate do
    sh "heroku run rake db:migrate --app pure-scrubland-1990"
  end
end
