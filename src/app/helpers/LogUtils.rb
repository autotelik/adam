require "logger"

# Automatically get logging to file and/or STDOUT by including this Module
# 
# Client can open/close additional loggers if required,
# for example to log to both STDOUT and a file
# Underlying is the standard ruby Logger class so the log methods
# accepts the standard log levels as first param e.g :
# 
#   log(:info, "blah")
#   log(:error, "blah") 
#   log(:debug, blah") 
#   etc
#   
# Upon instantiation will automatically look for --log param 
# and create a file based log, if no param found a STDOUT based log
# will automatically be created
# 
# Additional logs can be manually opened with open_log( handle ) where handle 
# is one of the STD streams or a file :
# 
#       a.open_log( STDOUT )
#       a.open_log( "/path/mylog.log" )
#
# Logs can also be closed by handle or all logs closed:
# 
#     c.close_all
#
#
# Open up logger and define format of message

class Logger

  def format_message(severity, timestamp, progname, msg)
    return "#{timestamp.strftime("%d-%m-%y %H:%M")} [#{severity}] - #{msg}\n" unless severity == 'DEBUG'

    return "#{timestamp.strftime("%d-%m-%y %H:%M")} [#{severity}] [#{__FILE__}]- #{msg}\n"
  end
end

module LogUtils

  @@log_utils_logs = {}
   
  def self.logs
    @@log_utils_logs
  end      
  
  def self.included( klass )
    
    klass.instance_eval{
       alias_method :_pre_log_initialize, :initialize
       define_method( :initialize ){ |*args|
         _setup_log
         _pre_log_initialize( *args )
       }
     }
  end

 private
 
  def _setup_log
    
    log_file = nil
    
    # Don't use OptParser or it ruins OptParser usage for everyone (even parse)
    # 
    ARGV.each_with_index do |a, i| 
      if( a == "--log")
        log_file = ARGV[ i + 1]
      end
    end

    open_log( log_file )
  end

 public
  
  def self.extended( obj )
     obj.instance_eval{ _setup_log }
  end

  def log( level, msg)
    @@log_utils_logs.each_value { |l| l.send( level.to_s, msg) }
  end
 
  def close_all()
    @@log_utils_logs = {}
  end
 
  def close( handle )
    @@log_utils_logs.delete( handle )
  end
   
  def open_log( handle = nil)
    if (handle.nil?)
      @@log_utils_logs[STDOUT] ||= Logger.new(STDOUT)
    else
      # log file rotated every seven days
      #VSS::log = Logger.new(log_file,7,'daily')
      @@log_utils_logs[handle] ||= Logger.new(handle)
    end
  end
end

class Exception  
  include LogUtils
  def info    
    msg = "#{self.class}: #{message}#$/#{backtrace.join($/)}"
    log :info, msg
    msg
  end
 end