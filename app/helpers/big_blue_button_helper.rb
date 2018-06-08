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

  def bigbluebutton_is_moderator(roles)
    roles = roles.split(",")
    moderators = (ENV['BIGBLUEBUTTON_MODERATOR_ROLES'] || 'administrator,instructor').split(",")
  end

  def bigbluebutton_username(launch_params, is_moderator = false)
    if launch_params["lis_person_name_full"]
      launch_params["lis_person_name_full"]
    elsif launch_params["lis_person_name_given"] && launch_params["lis_person_name_family"]
      launch_params["lis_person_name_given"] + " " + launch_params["lis_person_name_family"]
    elsif launch_params["lis_person_contact_email_primary"]
      launch_params["lis_person_contact_email_primary"].split("@").first
    elsif is_moderator
      'Moderator'
    else
      'Attendee'
    end
  end

  def is_moderator?(launch_roles)
    moderator_roles = (ENV['BIGBLUEBUTTON_MODERATOR_ROLES'] || BIGBLUEBUTTON_MODERATOR_ROLES).split(",")
    launch_roles = launch_roles.split(",")
    moderator_roles.each { |role|
      return true if launch_roles.include?(role)
    }
    false
  end
end
