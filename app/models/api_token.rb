class ApiToken < ActiveRecord::Base
  validates :token, :length => {:is => 40}

  def self.random
    uncached do
      if record = where(:active => true).order("RANDOM()").first()
        record.token
      else
        ENV["TOKEN"]
      end
    end
  end
end
