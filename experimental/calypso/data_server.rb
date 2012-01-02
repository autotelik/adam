# Author::    Tom Statter 
# Date::      Aug 2008
# Details::   A simple wrapper around the Calypso DS Connection
# Usage::     
#             args = ['-env', 'BLAH', '-user', 'calypso', '-password', 'xyz']
#                         
#             DataServer.instance.connect( args, 'UpdateAllBondQuotes' )
#             DataServer.instance.getRemoteProduct().getProducts("Bond", nil)
#             DataServer.instance.disconnect
#

#require '../../lib/java/log4j.jar'

#ENV['CLASSPATH'] << 'C:/SoftwareDev/JRuby/ADAM/lib/java/log4j.jar'

#include_class org.apache.log4j.Level

include_class com.calypso.tk.service.DSConnection
include_class com.calypso.tk.util.ConnectionUtil
include_class com.calypso.tk.util.ConnectException

require 'singleton'

class DataServer

  include Singleton
 
  attr_accessor :calDS, :args  
  
  def intialize
    @calDS = nil 
    @args  = []
  end
  
  
  # Parse arguments and choose most appropriate conenction method
  # Forms are : 
  #   args = ['-env', 'BLAH', '-user', 'calypso', '-password', 'xyz']
  #   args = ['-rmiPort', 1101, '-env', 'BLAH', '-user', 'calypso', '-password', 'xyz', '-host', 10.100.192.130]
  
  def connect( args, name )
    print "connecting"
    raise "Please pass array of connection params" unless args.class == Array
    @args = args
    begin

      if @args.include?('-rmiPort')

        port   = @args[ (@args.index('-rmiPort') + 1) ]
        env    = param_or_raise('-env')
        user   = param_or_raise('-user') 
        passwd = param_or_raise('-password')
        host   = param_or_raise('-host')
        @calDS = com.calypso.tk.util.ConnectionUtil.connect(port, env, name, user, passwd, host)
      else
        @args = args.to_java :String
        @calDS = com.calypso.tk.util.ConnectionUtil.connect(@args, name)
      end
     
    rescue ConnectException => e
      puts "ERROR : Failed to connect to DS"
      puts e.backtrace
      puts args
      raise e
    end
  end
  
  def connected?()
    return ! @calDS.nil?
  end
  
  def disconnect()
    begin
      @calDS.disconnect()
    rescue
      puts "ERROR : Failed to disconnect from DS"
      return
    end
  end
  
  def param_or_raise( param )
    if @args.include?( param ) 
      return args[ (@args.index(param) + 1) ]
    else
      raise "Error - No param #{param} specified in args"
    end
  end
  
  # Implement the Proxy to foward all calls to Calypso DS
  
  def method_missing(methodname, *args)  
    begin 
      @calDS.send(methodname, *args)  
    rescue
      puts "Failed in #{methodname} - Please ensure connect called prior to calling DataServer" if @calDS.nil?
      puts e.backtrace
    end
  end
  
end