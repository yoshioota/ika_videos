# == Schema Information
#
# Table name: credentials
#
#  id            :integer          not null, primary key
#  client_id     :string(255)
#  client_secret :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Credential < ActiveRecord::Base

  validates :client_id, presence: true
  validates :client_secret, presence: true

  def self.valid?
    return false if count.zero?
    first.valid?
  end
end
