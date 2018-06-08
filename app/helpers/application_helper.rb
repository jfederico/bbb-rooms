module ApplicationHelper
  def log_div(seed, n)
    div = seed
    for i in 1..n
      div += seed
    end
    logger.info div
  end

  def log_hash(h)
    log_div("*", 100)
    h.sort.map do |key, value|
      logger.info "#{key}: " + value
    end
    log_div("*", 100)
  end

  def random_password(length)
    o = [('a'..'z'), ('A'..'Z')].map { |i| i.to_a }.flatten
    password = (0...length).map { o[rand(o.length)] }.join
    return password
  end
end
