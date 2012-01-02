require 'logger'

@@logger = nil

def log
  if @@logger.nil?
    # TODO - mkdir unless dir exists?
    # TODO - productionize ... where should log files go in standard Win/OS app
    log_dir = ENV['TMP'] || ENV['TMPDIR'] || '/tmp'
    log_file = log_dir + '/adam.log'
    @@logger = Logger.new(log_file, 10, 100*1024)
    @@logger.level = Logger::INFO
  end
  @@logger
end

#We want timestamped log entries:

class Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_s(:log_format)} [#{severity}] - #{msg}\n"
  end
end