module LtiHelper
  def username(default)
    if @handler_params["lis_person_name_full"]
      @handler_params["lis_person_name_full"]
    elsif launch_params["lis_person_name_given"] && launch_params["lis_person_name_family"]
      launch_params["lis_person_name_given"] + " " + launch_params["lis_person_name_family"]
    elsif launch_params["lis_person_contact_email_primary"]
      launch_params["lis_person_contact_email_primary"].split("@").first
    else
      default
    end
  end

  def is_moderator?
    bigbluebutton_moderator_roles.each { |role|
      return true if is?(role)
    }
    false
  end

  def is_admin?
    is?("Administrator")
  end

  def is?(role)
    launch_roles.each { |launch_role|
      return true if launch_role.match(/#{role}/i)
    }
    false
  end

  def launch_roles
    @handler_params["roles"].split(",")
  end
end
