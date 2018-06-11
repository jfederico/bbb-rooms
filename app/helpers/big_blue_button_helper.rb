module BigBlueButtonHelper

  BIGBLUEBUTTON_ENDPOINT = "http://test-install.blindsidenetworks.com/bigbluebutton/"
  BIGBLUEBUTTON_SECRET = "8cd8ef52e8e101574e400365b55e11a6"
  BIGBLUEBUTTON_MODERATOR_ROLES = "Instructor,Faculty,Teacher,Mentor,Administrator,Admin"

  def bigbluebutton_endpoint
    endpoint = ENV['BIGBLUEBUTTON_ENDPOINT'] || BIGBLUEBUTTON_ENDPOINT
    endpoint += 'api'
    endpoint
  end

  def bigbluebutton_secret
    secret = ENV['BIGBLUEBUTTON_SECRET'] || BIGBLUEBUTTON_SECRET
    secret
  end

  def bigbluebutton_moderator_roles
    (ENV['BIGBLUEBUTTON_MODERATOR_ROLES'] || BIGBLUEBUTTON_MODERATOR_ROLES).split(",")
  end
end
