require "./git_info"
require './parser_util'
require "active_record"
require "activerecord-postgres-hstore"
require 'uri_template'
require 'pry'

class Repo < ActiveRecord::Base
  serialize :response, ActiveRecord::Coders::Hstore
  serialize :data, ActiveRecord::Coders::Hstore

  scope :with_gemfiles, where("(data->'Gemfile') IS NOT NULL")

  def self.process_gemfiles
    # This finds repos that have data (data IS NOT NULL)
    # but don't have a Gemfile key in that data
    Repo.where("NOT data ? 'Gemfile'").limit(1000).map(&:store_gemfile)
  end

  def self.process_trees
    Repo.where("data IS NULL").limit(1000).map(&:refresh_tree)
  end

  def self.create_or_update_from_github(data)
    repo = find_or_initialize_by_id(data.id)

    if owner = data.delete("owner")
      Person.create_or_update_from_github(owner)
      data["owner_id"] = (owner.id)
    end

    puts "ID: #{repo.id}"
    repo.response = data
    repo.save!

    return repo
  end

  def api
    GitInfo.instance
  end

  def get_repo_contents(path)
    uri = URITemplate.new(response["contents_url"]).expand(:path => path)

    result = api.get_request uri

    Base64.decode64 result.content
  end

  def fetch_gemfile
    retries = 2
    begin
      get_repo_contents("Gemfile")
    rescue Github::Error::NotFound
      return nil
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
    end
  end

  def default_tree_url
    default_branch = "master"

    URITemplate.new(response["trees_url"]).expand(
      :sha => default_branch
    )
  end

  def refresh_tree(force=false)
    if !data["tree"] || force
      puts "refreshing_tree for #{id}"

      begin
        res = api.get_request default_tree_url, :recursive => true

        self.data["tree"] = process_tree(res.tree)
        save!
      rescue Github::Error::NotFound
        self.data["tree"] = nil
        save!
      rescue Faraday::Error::ConnectionFailed, Github::Error::ServiceError => e
        puts e.message
      end
    end
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
