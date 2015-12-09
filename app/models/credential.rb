class Credential < ActiveRecord::Base

  validates :client_id, presence: true
  validates :client_secret, presence: true

  def self.valid?
    return false if count.zero?
    first.valid?
  end
end
