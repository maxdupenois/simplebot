class SimpleBot::BasicBot
  
  def self.register(name)
    SimpleBot::BOTS[name] = self
  end



  def start(nickname, username)
    irc = LightWeightIrcConnector.new
    irc.connect SimpleBot::CONFIG.hostname, SimpleBot::CONFIG.port, 
                username, SimpleBot::CONFIG.password, SimpleBot::CONFIG.ssl
    irc.nick! nickname
    irc.join! SimpleBot::CONFIG.channel
  
    irc.listen do |user, channel, message|
      yield(irc, user, channel, message)
    end
  
    irc.close
  end

end