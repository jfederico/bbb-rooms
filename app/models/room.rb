class Room < ApplicationRecord
  before_save :default_values

  def default_values
    self.handler ||= Digest::SHA1.hexdigest(SecureRandom.uuid)
  end
end
