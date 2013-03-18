class SimpleBot::BurgerBot < SimpleBot::BasicBot
  register "burgerbot"
  
  MINUTE  = 60
  HOUR    = MINUTE*60
  DAY     = HOUR*24

  def time_between(date_start, date_end)
    diff = (date_end.to_time.to_i - date_start.to_time.to_i).to_f
    days = (diff / DAY).floor
    remainder = diff % DAY
    hours = (remainder / HOUR).floor
    remainder = remainder % HOUR
    minutes = (remainder / MINUTE).floor
    remainder = remainder % MINUTE
    seconds = remainder
    parts = []
    parts << "#{days.to_i} Days" if(days > 0) 
    parts << "#{hours.to_i} Hrs" if(hours > 0)
    parts << "#{minutes.to_i} Mins" if(minutes > 0)
    parts << "#{seconds.to_i} Secs" if(seconds > 0)
    parts.join(" ")
  end

  def next_friday
    now = DateTime.now
    if(now.friday? && now.hour < 13)
      return DateTime.new(now.year, now.month, now.day, 13, 0, 0)
    end
    #friday = 5
    day_diff = 5 - now.cwday
    day_diff = (day_diff > 0 ? day_diff : 7 + day_diff.abs)

    day = (now + day_diff).day

    DateTime.new(now.year, now.month, day, 13, 0, 0) 
  end
  
  
  def run
    start("fwd_burgertime", "fwd_burgertime") do |irc_connector, user, channel, message|
      if(message =~ /burger/i && (message =~ /when/i || message =~ /time/i) )
        irc_connector.message! "Burgers in T - #{time_between(DateTime.now, next_friday)}" 
      end
    end
  end
  
end