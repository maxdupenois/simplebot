class SimpleBot::LunchMe < SimpleBot::CommandBot
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
  

  
  def add_lunch_option(user, type, *restaraunt)
    LUNCH_OPTS[type.downcase] = [] if LUNCH_OPTS[type.downcase].nil?
    LUNCH_OPTS[type.downcase] << restaraunt.join(" ").capitalize
    "No worries #{user}, i've added '#{restaraunt.join(" ").capitalize}' to lunch options type #{type}"
  end
  
  def choose_lunch_option(user, *args)
    if(args[0] && LUNCH_OPTS[args[0].downcase]) 
      type = args[0].downcase
    else 
      type = LUNCH_OPTS.keys.sample
    end
    restaurant = LUNCH_OPTS[type].sample
    "#{user} you should go to #{restaurant} to consume #{type}!"
  end
  
  def list(user, *args)
    if(args[0] && LUNCH_OPTS[args[0].downcase]) 
      return "Ah, #{args[0]}, I know of #{LUNCH_OPTS[args[0].downcase].size} #{args[0]} place(s) to eat: #{LUNCH_OPTS[args[0].downcase].join(", ")}"
    end
    LUNCH_OPTS.reduce([]) do |memo, (key, val)|
      memo << "#{key} => [#{val.join(", ")}]"
      memo
    end.join(" | ")
  end
  
  def should(user, person, *args)
    declarative = person.downcase == "i" ?  "you" : person.downcase.capitalize
    name = person.downcase == "i" ?  user : person.downcase.capitalize 
    return "Should #{declarative} what?" if(args.empty?)
    if args[0] =~ /eat/i
      return "Probably, it's considered a good idea by most cultures" if(args.size == 1)
      return ["No that's a truly terrible idea, you've let me down, you've let the room down, but most of all you've let Rylon down",
              "Genius, I think you're on to something, #{declarative} should definitely partake in some tasty #{args[1..-1].join(" ")}"].sample
    elsif args[0] =~ /go/i
      return "Go on now go #{name}, walk out the door, just turn around now, you're not welcome any more." if(args.size == 1)
      return ["#{name}, your mother would be so disappointed in your behaviour, I don't want you hanging around with that samwho any more, he's a bad example.",
              "#{declarative} should definitely go #{args[1..-1].join(" ")}, this may well be the greatest idea since the invention of extra large condom"].sample
    else 
      return "I'm young and don't know what #{args.join(" ")} means, maybe #{name} could show me later tonight? I'll bring the wine."
    end  
  end
  
  def run
    command_prepend "lunchme:"
    command "add", "Allows you to add new lunch options", :add_lunch_option, 2
    command "choose", "Randomly selects a lunch option, can be given a type", :choose_lunch_option, 0
    command "list", "Shows the available options currently held in memory, can be given a type", :list, 0
    command "should", "Slightly smarter more interesting", :should, 1
    
    start("fwd_lunchme", "fwd_lunchme")
  end
end