require 'colored'
require 'yaml'
require 'socket'
require 'date'
require 'openssl'
require 'optparse'
require 'ostruct'






module SimpleBot
  VERSION             = "0.1a"
  DEFAULT_CONFIG_LOC  = File.join(File.dirname(__FILE__), *%w[.. irc.connection.yml])
  
  BOTS = {}
  
  CONFIG = OpenStruct.new
  CONFIG.hostname = nil 
  CONFIG.channel = nil 
  CONFIG.password = nil
  CONFIG.port = nil
  CONFIG.ssl = false
  
  def configure
    begin 
      info = YAML.load_file(DEFAULT_CONFIG_LOC)
      CONFIG.hostname = info["connection"]["hostname"]
      CONFIG.port     = info["connection"]["port"]
      CONFIG.channel  = info["connection"]["channel"]
      CONFIG.password = info["connection"]["password"]
      CONFIG.ssl = info["connection"]["ssl"]
    rescue => e
      puts "Cannot load defaults #{e.message}".red
    end
    user_config = OpenStruct.new
    yield(user_config) if block_given?
    CONFIG.hostname = user_config.hostname if (user_config.hostname)
    CONFIG.port     = user_config.port if (user_config.port)
    CONFIG.channel  = user_config.channel if (user_config.channel)
    CONFIG.password = user_config.password if (user_config.password)
    CONFIG.ssl = user_config.ssl if (!user_config.ssl.nil?)
  end
  module_function :configure
  
end

require File.join(File.dirname(__FILE__), *%w[simple_bot lightweight_irc_connector])
require File.join(File.dirname(__FILE__), *%w[simple_bot basic_bot])


Dir[File.join(File.dirname(__FILE__), "simple_bot", "bots", '*.rb')].each do |f|
  require f
end