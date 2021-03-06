# coding: utf-8

require "./git_info"
require './parser_util'
require "active_record"
require "activerecord-postgres-hstore"
require 'uri_template'

class Repo < ActiveRecord::Base
  serialize :response, ActiveRecord::Coders::Hstore
  serialize :data, ActiveRecord::Coders::Hstore
  serialize :full_data, ActiveRecord::Coders::Hstore

  scope :with_gemfiles, where("data ? 'Gemfile'").where("(data->'Gemfile') IS NOT NULL")
  scope :with_trees, where("data ? 'tree'").where("(data->'tree') IS NOT NULL")

  def self.process_gemfiles
    # This finds repos that have data (data IS NOT NULL)
    # but don't have a Gemfile key in that data
    Repo.with_trees.where("NOT data ? 'Gemfile'").limit(100).map(&:store_gemfile)
  end

  def self.process_trees
    Repo.where("data IS NULL").limit(100).map(&:refresh_tree)
  end

  def self.create_or_update_from_github(data)
    repo = find_or_initialize_by_id(data.id)

    if owner = data.delete("owner")
      Person.create_or_update_from_github(owner)
      data["owner_id"] = (owner.id)
    end

    puts "ID: #{repo.id}"
    repo.response = data
    begin
      repo.save!
    rescue
      # binding.pry
    end

    return repo
  end

  def api
    GitInfo.instance
  end

  def gemfile
    data["Gemfile"]
  end

  def update_state
    if master_branch
      self.state = "master_branch"
    elsif error
      self.state = "error"
    elsif gemfile
      self.state = "gemfile"
    elsif data["tree"]
      self.tree = data["tree"]

      if tree.empty?
        self.state = "no_tree"
      else
        self.state = "tree"
      end
    else
      self.state = "needs_master"
    end

    save
  end

  def ensure_master_branch
    puts "Fecting full data for #{id}"
    if full_data.empty?
      get_full_data
    else
      # Probably sholdn't be here
      puts "Have full data, but haven't set master branch"
    end
  end

  def get_full_data
    uri = response["url"]

    begin
      result = api.get_request(uri, access_token: ApiToken.random)
      handle_full_data(result.to_hash)
    rescue Github::Error::NotFound => e
      # Repository ma no longer be public?
      self.error = e.message
      save

      puts e
    rescue Github::Error::Forbidden => e # Rate limit exceeded
      puts e.message

      if e.message =~ /Repository access blocked/
        self.error = e.message
        save

        return # Not rate limit, some other permission error
      end

      sleep 10

      retry
    rescue Github::Error::ServiceError => e
      puts e
    rescue Faraday::Error::ConnectionFailed, Github::Error::InternalServerError => e
      puts e
    end
  end

  def handle_full_data(result)
    self.master_branch = result["default_branch"] || result["master_branch"]

    result.delete "owner"

    if source = result.delete("source")
      self.source_id = source["id"]
    end

    if parent = result.delete("parent")
      self.parent_id = parent["id"]
    end

    self.full_data = result

    self.save!
  end

  def get_repo_contents(path)
    uri = URITemplate.new(response["contents_url"]).expand(:path => path)

    result = api.get_request uri

    if result.type == "file"
      Base64.decode64 result.content
    else
      puts result.type
      data["Gemfile"] = nil
      save!

      return nil
    end
  end

  def fetch_gemfile
    retries = 0
    begin
      get_repo_contents("Gemfile")
    rescue Github::Error::NotFound
      data["Gemfile"] = nil
      save!

      return nil
    rescue Github::Error::Forbidden => e # Rate limit exceeded
      puts e.message
      sleep 120

      retry
    rescue Github::Error::ServiceError => e
      # print "\a"
      # binding.pry
    rescue Faraday::Error::ConnectionFailed, Github::Error::InternalServerError => e
      puts e

      retries -= 1

      if retries >= 0
        puts "Sleeping for 1 second then retrying #{retries} more times"
        sleep 1

        retry
      end
    end
  end

  def store_gemfile
    if tree = data["tree"]
      if tree.include?("Gemfile")
        puts "Retrieving Gemfile for #{id}"

        if data["Gemfile"] = fetch_gemfile
          save!
        end
      else
        puts "No Gemfile in tree for #{id}"

        data["Gemfile"] = nil
        save!
      end
    else
      puts "No tree data"
    end
  end

  def default_tree_url
    default_branch = master_branch || "master"

    URITemplate.new(response["trees_url"]).expand(
      :sha => master_branch
    )
  end

  def refresh_tree(force=false)
    if !data["tree"] || force
      puts "refreshing_tree for #{id}"

      begin
        res = api.get_request default_tree_url, :recursive => true

        self.data["tree"] = process_tree(res.tree)
        save!
      rescue Github::Error::NotFound => e
        puts e.message

        self.data["tree"] = nil
        save!
      rescue Github::Error::Forbidden => e # Rate limit exceeded
        puts e.message
        sleep 120
        retry
      rescue Github::Error::ServiceUnavailable => e
        puts e.message
      rescue Faraday::Error::ConnectionFailed, Github::Error::ServiceError => e
        if e.respond_to? :http_headers
          if e.http_headers["status"] =~ /409/
            self.data["tree"] = nil
            save!
          else
            puts e.message
          end
        else
          puts e.message
        end
      end
    end
  end

  def fetch_full_data
    # TODO: Get full repo data
  end

  def process_tree(tree)
    tree.map(&:path)
  end

  # Converts the text of a gemfile to a list of dependencies
  def parse_gemfile
    ParserUtil.gemfile(data["Gemfile"])
  end
end

class Person < ActiveRecord::Base
  serialize :response, ActiveRecord::Coders::Hstore
  serialize :data, ActiveRecord::Coders::Hstore

  def self.create_or_update_from_github(data)
    person = find_or_initialize_by_id(data.id)
    person.response = data
    person.save!

    return person
  end
end
