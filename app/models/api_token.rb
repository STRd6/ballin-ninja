class ApiToken < ActiveRecord::Base
  validates :token, :length => {:is => 40}

  def self.random
    order("RANDOM()").first().token
  end
end
