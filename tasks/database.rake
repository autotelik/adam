# Copyright:: Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     July 2011
# License::   MIT
#
# Should be called from root Rakefile - which sorts out load paths, DB etc

# Pull out some of the rails tasks here and implement ourselves
# too much Rails config/boot needed (beyond the AR stuff) to run them via "require 'tasks/rails'"
#

# Connect to DB and setup environment, load AR models etc
task :setup do
  Boot::setup
end

# Connect to DB only - no additional setup, useful for simple sql loads etc when
# we don't need to load AR models etc
task :connect do
  Boot::db_connect
end

namespace :db do

  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
  task :migrate => :connect do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

  desc "Load database with data defined in ALL load scripts in db/data"
  task :load_all => :setup do
    puts "Starting Data Load"
    Dir.glob("db/data/*.rb").sort.each do |loader| require loader end
    puts "Data Load Complete"
  end

  Dir.glob("db/data/*.rb").sort.each do |loader|
    l = loader.gsub('.rb', '').split("/").last
    desc "Load database with data from load script : #{l}"
    task "#{l}".intern => :setup do
      puts "Data Load #{l} - Starting"
      require loader
      puts "Data Load #{l} - Complete"
    end
  end

  # Notes on MySQL - Such a large file can cause error with 'max_allowed_packet'
  #  Under windows this can be set for the Server in
  #   C:\Program Files\MySQL\MySQL Server 5.0\my.ini
  #  Set via :
  #   [mysqld]
  #     max_allowed_packet=100M
  #
  #  May also be required for the client connection :
  #   WINDIR\my.cnf
  # =>  C:\> echo %WINDIR%

	desc "Import a DB dump."
	task :import_sql => :connect do
    File.open("db/data/full_calypso.sql") do |f|
	    sql = f.read
      #puts ActiveRecord::Base.connection.class
	    ActiveRecord::Base.connection.execute(sql)
	  end
	end

end