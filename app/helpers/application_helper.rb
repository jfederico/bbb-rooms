module ApplicationHelper
  def log_div(seed, n)
    div = seed
    n.times do
      div += seed
    end
    div
  end

  def log_hash(h)
    logger.info log_div('*', 100)
    h.sort.map do |key, value|
      logger.info "#{key}: " + value
    end
    logger.info log_div('*', 100)
  end

  def random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    (0...length).map { o[rand(o.length)] }.join
  end
end
