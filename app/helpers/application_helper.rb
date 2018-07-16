module ApplicationHelper

  def random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...length).map { o[rand(o.length)] }.join
  end

end
