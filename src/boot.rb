# Copyright:: Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Dec 2011
# License::   Dual license : permission given to use this code under two licenses.
# => TBD one license (probably GPL) for free (no cost) programs
# => TBD one for commercial programs
#
#
# Setup Ruby and Java include dirs - load_path and classpath to pull in all
# required jars and pre load project files specifically so that ActiveRecord can work

## THE ADAM 3rd party gems - do it manually for now

# TODO - automate this - lots of weird differences in file/jar procesisng of paths
# makes this trickier than it looks
#[ File.join('..', 'lib', 'ruby', "**") ].each do |path|
#  Dir.glob(path).each do |directory|
#   puts "ADD #{directory}"
#    add_to_load_path(path) if File.directory?(directory)
#  #  puts "ADD LOAD_PATH #{directory} - #{directory.class}" if File.directory?(directory)
#  end
#end

case Config::CONFIG["host_os"]

when /darwin/i # OSX specific code


when /^win|mswin/i # Windows specific code
  $:.unshift('jruby-win32ole-0.8.4/lib')
  require 'jruby-win32ole'

  require 'jexcel_win32'

when /linux/i # Linux specific code
end

require 'erb'
require 'active_record'

module Boot
  def self.db_connect( env = 'production')

    database_config = File.expand_path( File.join(ADAM_ROOT_PATH, '/config/database.yml'))

    configuration = {:rails_env => env }

    # Some active record stuff seems to rely on the RAILS_ENV beign set ?
 
    ENV['RAILS_ENV'] = configuration[:rails_env]

    configuration[:database_configuration] = YAML::load(ERB.new(IO.read(database_config)).result)
    db = configuration[:database_configuration][ configuration[:rails_env] ]

    puts "Setting DB Config - #{db.inspect}"
    ActiveRecord::Base.configurations = db

    puts "Connecting to DB"
    ActiveRecord::Base.establish_connection( db )

    puts "Connected to DB Config - #{configuration[:rails_env]}"
  end

  def self.setup
    
    begin
      db_connect
    rescue => e
      puts "ERROR -Failed to connect to DB", e
    end 
  end

  def self.models
    # Pre-load Model
    [ File.join(ADAM_SRC_PATH, 'app', 'models/**', "*.rb")].each do |path|
      Dir.glob(path).each do |file| require file end
    end
  end

  def self.controllers

    require File.join(ADAM_SRC_PATH, 'app', 'adam_controller')

    # Pre-load Controllers
    [ File.join(ADAM_SRC_PATH, 'app', 'controllers/**', "*.rb")].each do |path|
      Dir.glob(path).each do |file| require file end
    end
  end

end