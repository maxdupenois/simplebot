class SimpleBot::CommandBot < SimpleBot::BasicBot
  
  def initialize
    @commands = {}
    @prepend = nil
  end
  
  def command name, description, method, argument_length
    name = (name.is_a?(Symbol) ? name : name.to_sym)
    @commands[name] = OpenStruct.new
    @commands[name].description = description
    @commands[name].method_call = method
    @commands[name].argument_length = argument_length
  end
  
  def command_prepend prepend, caseinsensitive = false
    @prepend = (caseinsensitive ? /^#{prepend}/i :  /^#{prepend}/)
  end
  
  def parse_command(user, message)
    parts = message.split(/\s/)
    if(parts.size == 0)
      if @commands[:no_command_given]
        return self.send @commands[:no_command_given].method_call user
      else
        return "I have no idea what you're trying to do #{user}, have you been drinking?"
      end
    end
    command = @commands[parts[0].to_sym]
    if(command.nil?)
      if @commands[:unknown_command_given]
        return self.send @commands[:unknown_command_given].method_call user
      else
        return "#{user}, are you just making up words? I'd lay off the #{%w[heroin lsd bath\ salts cocaine].sample} if I were you"
      end
    end
    arg_length = parts.size - 1 
    args = arg_length > 0 ? parts[1..-1] : []
    
    if(command.argument_length > arg_length)
      if @commands[:not_enough_arguments]
        return self.send @commands[:not_enough_arguments].method_call user
      else
        return "#{user}, focus dammnit! That command takes at least #{command.argument_length} arguments. Stop getting distracted by the danish spanking."
      end
    end
    begin
      self.send command.method_call, user, *args
    rescue => e
      return "Everyone, try to hide your disappointment in #{user}, they screwed up but they try so hard. [#{e.message}]"
    end
  end
  
  def show_help(*args)
    @commands.reduce([]) do |memo, (key, command)|
      memo << "#{key} => #{command.description} args: #{command.argument_length}"
      memo
    end.join(" | ")
  end
  
  def start(nickname, username)
    command "help", "Shows this help message", :show_help, 0
    
    super(nickname, username) do |irc, user, channel, message|
      if @prepend.nil? || message =~ @prepend
        message.gsub!(@prepend, "") if(@prepend)
        user = user.gsub(/^([a-zA-Z0-9_\-]+).*$/, '\1')
        result = parse_command(user, message.strip)
        irc.message! result if !result.nil? && !result.empty?
      end
    
    end
  end

end