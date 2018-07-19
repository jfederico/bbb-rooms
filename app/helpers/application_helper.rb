module ApplicationHelper

  def random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...length).map { o[rand(o.length)] }.join
  end

  def omniauth_authorize_path(provider)
    "#{ENV['RELATIVE_URL_ROOT'] ? '/' + ENV['RELATIVE_URL_ROOT'] : ''}/auth/#{provider.to_s}"
  end

  def lti_broker_url
    "#{ENV['OMNIAUTH_BBBLTIBROKER_SITE']}#{ENV['OMNIAUTH_BBBLTIBROKER_ROOT'] ? '/' + ENV['OMNIAUTH_BBBLTIBROKER_ROOT'] : ''}"
  end

  def lti_broker_api_v1_sso_url
    "#{lti_broker_url}/api/v1/sso"
  end

  def omniauth_client_token
    client_id = ENV['OMNIAUTH_BBBLTIBROKER_KEY']
    client_secret = ENV['OMNIAUTH_BBBLTIBROKER_SECRET']
    response = RestClient.post("#{lti_broker_url}/oauth/token", {grant_type: 'client_credentials', client_id: client_id, client_secret: client_secret})
    JSON.parse(response)["access_token"]
  end

  def omniauth_provider?(provider)
    OmniAuth::strategies.each do |strategy|
      return true if provider.to_s.downcase == strategy.to_s.demodulize.downcase
    end
    false
  end

end
