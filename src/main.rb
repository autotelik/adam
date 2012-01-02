#===============================================================================
# Much of the platform specific code should be called before Swing is touched.
# The useScreenMenuBar is an example of this.
require 'rbconfig'
require 'java'

#===============================================================================
# Platform specific operations, feel free to remove or override any of these
# that don't work for your platform/application

case Config::CONFIG["host_os"]
when /darwin/i # OSX specific code
  java.lang.System.set_property("apple.laf.useScreenMenuBar", "true")
when /^win|mswin/i # Windows specific code
when /linux/i # Linux specific code
end

# End of platform specific code
#===============================================================================
$LOAD_PATH << File.expand_path(File.dirname(__FILE__))

require 'manifest'

# Set up global error handling so that it is consistantly logged or outputed
# You will probably want to replace the puts with your application's logger
def show_error_dialog_and_exit(exception, thread=nil)
  puts "Error in application"
  puts "#{exception.class} - #{exception}"
  if exception.kind_of? Exception
    puts exception.backtrace.join("\n")
  else
    # Workaround for JRuby issue #2673, getStackTrace returning an empty array
    output_stream = java.io.ByteArrayOutputStream.new
    exception.printStackTrace(java.io.PrintStream.new(output_stream))
    puts output_stream.to_string
  end

  # Your error handling code goes here
  
  # Show error dialog informing the user that there was an error
  title = "Application Error"
  message = "The application has encountered an error and must shut down."
  
  javax.swing.JOptionPane.show_message_dialog(nil, message, title, javax.swing.JOptionPane::DEFAULT_OPTION)
  java.lang.System.exit(0)
end

GlobalErrorHandler.on_error {|exception, thread| show_error_dialog_and_exit(exception, thread) }

class CancelException < Exception
end


# Your application code goes here

begin
  include_class javax.swing.UIManager
  include_class org.jvnet.substance.skin.SubstanceOfficeSilver2007LookAndFeel

  #javax.swing.UIManager.set_look_and_feel javax.swing.UIManager.getSystemLookAndFeelClassName
  javax.swing.UIManager.set_look_and_feel "org.jvnet.substance.skin.SubstanceOfficeSilver2007LookAndFeel"
  #rescue UnsupportedLookAndFeelException => e
  #  $stderr << "Error in application:\n#{e}\n#{e.message}"
  #  puts "Error loading supplied look and feel on this OS\n#{e}\n#{e.backtrace}"
rescue Exception => e
  $stderr << "Error starting GUI manager :\n#{e}\n#{e.message}"
  puts "Error loading look and feel\n#{e}\n#{e.backtrace}"
end

# Auto require main Adam code and boot items like active record
require 'boot'

require 'active_record_logging'   # Outside Rails so we need to implement our own
ActiveRecord::Base.logger = log

Boot::setup

Boot::models
Boot::controllers

puts "System Booted - Application loaded"

puts "Starting GUI Application"

begin
  AdamController.instance.open
rescue => e
  puts "Error in application:\n#{e}\n#{e.message}"
  e.backtrace.each {|b| puts "#{b}\n" }
  # Additional error handling goes here
  java.lang.System.exit(1)
  show_error_dialog_and_exit(e)
end