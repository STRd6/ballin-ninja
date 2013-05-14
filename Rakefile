require "./app"
require 'sinatra/activerecord/rake'
require "./git_info"

task :process_hella_repos do
  g = GitInfo.new

  while true do
    g.pull_repos
  end
end

task :process do
  g = GitInfo.new

  g.pull_repos
end

task :process_trees do
  while true do
    puts "Processing some trees"
    Repo.process_trees

    sleep 60
  end
end

task :process_gemfiles do
  while true do
    puts "Processing some gemfiles"
    Repo.process_gemfiles

    sleep 120
  end
end

task :dump_db do
  sh "pg_dump -Fc --no-acl --no-owner -h localhost git_info > mydb.dump"
end
