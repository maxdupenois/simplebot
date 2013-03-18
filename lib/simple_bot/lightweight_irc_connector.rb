
class LightWeightIrcConnector
  
  @socket = nil
  @ssl = false
  @channel = nil
  def connect(hostname, port, user, password =nil, ssl=false) 
    puts "Connecting to #{hostname}:#{port}#{(ssl ? " using ssl": "")}".green
    socket = TCPSocket.new hostname, port
    @ssl = ssl
    if @ssl
      ssl_context = OpenSSL::SSL::SSLContext.new
      ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
      socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
      socket.sync_close = true
      socket.connect
    end
    @socket = socket
    self.pass! password if(password)
    self.user! user, "forward.co.uk", "ircbots", user
  end
  
  def listen
    while line = @socket.gets
      begin 
        parsed = line_parse(line)
        if parsed[:command] == :PING
          pong! parsed[:args][0]
        elsif parsed[:command] == :PRIVMSG
          yield(parsed[:user], parsed[:args][0], parsed[:args][1])
        else
          puts "SERVER: #{[parsed[:user], parsed[:command], parsed[:args].join(" ")].join(" ")}".blue
        end
      rescue => e
        puts "FAILED TO PARSE LINE #{e.message}".red.bold
        # e.backtrace.each {|b| p b}
      end
    end
  end
  
  def line_parse(line)
    # :draximillian1!~Adium@81.19.48.130 PRIVMSG #testasdasdasdasdasdsadasd :burgertimetestbo: sup\r\n"
    line.strip!
    user,command = nil
    arguments = line.gsub(/^(?:\:?([^.]+\.[^\s]+)\s)?([A-Z]+)(.*)/) do 
      user = $1
      command = $2.to_sym
      $3
    end.strip
    current_arg = nil
    args = []
    arguments.split(/\s+/).each do |part|
      if(part !~ /^:.*$/)
        if current_arg 
          current_arg << part
        else
          args << part
        end
      else
        args << current_arg.join(" ") if current_arg
        current_arg = []
        current_arg << part[1..-1]
      end
    end
    args << current_arg.join(" ") if current_arg
    # p "USER #{user} COMMAND #{command} ARGS #{args.inspect}"
    {:user => user, :command => command, :args => args}
  end
  
  def close
    @socket.close
  end
 
  def pass!(password)
    self.cmd "PASS #{password}"
  end
  
  def pong!(server)
    self.cmd "PONG #{server}"
  end
  
  def user!(user, hostname, servername, realname)
    self.cmd "USER #{user} #{hostname} #{servername} #{realname}"
  end
  
  def nick!(nickname)
    self.cmd "NICK #{nickname}"
  end
  
  
  def join!(channel)
    @channel = channel
    self.cmd "JOIN ##{channel}" 
  end
  
  def message!(message)
    self.cmd "PRIVMSG ##{@channel} :#{message}" 
  end
  
  
  def cmd command
    puts "SEND: #{command}".cyan
    if(@ssl)
      @socket.puts "#{command}\r\n", 0
    else
      @socket.send "#{command}\r\n", 0
    end
  end
  
end