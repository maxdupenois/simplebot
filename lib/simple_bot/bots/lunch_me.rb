class SimpleBot::LunchMe < SimpleBot::BasicBot
  register "lunchme"
  
  LUNCH_OPTS = {
    "pasta" => ["Al Parco", "Rosso Pomodoro"], 
    "burger" => ["Foundry", "Blues Kitchen", "Byron", "Centro Cafe", "Hache"], 
    "pizza" => ["Chico's", "Centro Cafe", "Rosso Pomodoro"], 
    "burrito" => ["Centro Cafe"],
    "thai" => ["Taste of Siam"],
    "steak" => ["Patagonia"],
    "falafel" => ["Some falafel place"],
    "miscellaneous" => ["Blues Kitchen", "Camden Bar and Kitchen"]
  }
  
  class Command
    @@commands = {}
    def self.add(name, method, arg_length)
      @@commands[name] = {:method => method, :length => arg_length}
    end
    def self.commands
      @@commands
    end
    
    def self.run(bot, name, args)
      return "You speak to your mother with that mouth" if([:fuck, :shit, :wanker, :dick].include?(name))
      return "Command '#{name}' not recognised" if(@@commands[name].nil?)
      cmd = @@commands[name]
      return "Command '#{name}' requires #{cmd[:length]} arguments" if(cmd[:length] > args.size)
      bot.send(cmd[:method], *args)
    end
    
  end
  
  Command.add(:add, :add_lunch_option, 2)
  Command.add(:choose, :choose_lunch_option, 0)
  Command.add(:help, :list_commands, 0)
  
  def list_commands
    str = "Commands: "
    str += Command.commands.reduce([]) do |memo, (key, val)|
      memo << "'#{key}' [#{val[:length]} args]"
    end.join("; ")
  end
  
  def add_lunch_option(type, *restaraunt)
    LUNCH_OPTS[type] = [] if LUNCH_OPTS[type].nil?
    LUNCH_OPTS[type] << restaraunt.join(" ").capitalize
    "Added '#{restaraunt.join(" ").capitalize}' to lunch options type #{type}"
  end
  
  def choose_lunch_option
    type = LUNCH_OPTS.keys.sample
    restaurant = LUNCH_OPTS[type].sample
    "You should go to #{restaurant} to consume #{type}!"
  end
  
  def parse_command(command)
    parts = command.strip.split(" ").map(&:downcase)
    if parts.size == 0
      return "I have no idea what you want from me."
    end
    args = (parts.length > 1 ? parts[1..-1] : [])
    return Command.run(self, parts[0].to_sym, args)
  end
  
  def run
    start("fwd_lunchme", "fwd_lunchme") do |irc, user, channel, message|
      if message =~ /^lunchme:/
        irc.message! parse_command(message.gsub(/^lunchme:/, ""))
      end
    end
  end
end