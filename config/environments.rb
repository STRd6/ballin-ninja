require "active_record"
require "activerecord-postgres-hstore"

module DB
  def self.connect
    # Database connection
    db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/git_info')

    ActiveRecord::Base.establish_connection(
      :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
    )
  end
end
# ActiveRecord::Base.logger = Logger.new(STDOUT)
