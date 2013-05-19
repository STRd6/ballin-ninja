#!/usr/bin/env ruby

require "github_api"
require "./config/environments"
require "./models"
require "./app/models/api_token"

class GitInfo
  attr_reader :github

  def self.instance
    @instance ||= Github.new(oauth_token: ENV["TOKEN"])
  end

  def initialize
    @github = Github.new(oauth_token: ENV["TOKEN"])
  end

  def pull_repos
    since = Repo.maximum(:id)

    begin
      repos = github.get_request "/repositories?since=#{since}"
    rescue Faraday::Error::ConnectionFailed, Github::Error::ServiceError => e
      puts e.message

      sleep 60

      retry
    rescue Github::Error::Forbidden => e # This happens when we hit our rate-limit
      puts e.message

      sleep 60

      retry
    end

    puts repos.headers.ratelimit_remaining

    repos.each do |repo|
      Repo.create_or_update_from_github(repo)
    end

    return
  end

  def process_repos_for_user(name)
    repos = github.repos.list(user: name)

    repos.each do |repo|
      process_repo name, repo.name
    end
  end

  def process_repo(user, repo_name)
    puts "processing #{user}/#{repo_name}"
    repo = Repo.lookup(user, repo_name)

    begin
      gemfile_text = get_gemfile(user, repo_name)

      Dependency.where(:repo_id => repo.id).delete_all

      parse_gemfile(gemfile_text).each do |dependency|
        gem = RubyGem.find_or_create_by_name(dependency)

        Dependency.create repo_id: repo.id, ruby_gem_id: gem.id
      end

      puts "Added dependencies from Gemfile"

    rescue Github::Error::NotFound
      puts "Could not find Gemfile for #{user}/#{repo_name}"
    rescue Github::Error::Forbidden => e
      puts e.message
      n = 60
      puts "sleeping for #{n} seconds"
      sleep n
      retry
    rescue Exception => e
      puts "EXCEPTION: #{e.message}"
    end
  end

  def get_gemfile(user, repo)
    result = github.repos.contents.get user, repo, "Gemfile"

    Base64.decode64 result.content
  end

end
