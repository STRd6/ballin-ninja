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
