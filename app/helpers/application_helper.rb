module ApplicationHelper
  def random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    password = (0...length).map { o[rand(o.length)] }.join
    return password
  end
end
