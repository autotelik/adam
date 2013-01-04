Dir.glob(File.expand_path(File.dirname(__FILE__) + "/**/*").gsub('%20', ' ')).each do |directory|
  #puts "DEBUG: ADD To LOAD PATH #{directory}" if File.directory?(directory)
  $LOAD_PATH << directory if File.directory?(directory)
end

# Monkeybars requires, this pulls in the requisite libraries needed for
# Monkeybars to operate.

require 'resolver'

def monkeybars_jar path
  Dir.glob(path).select { |f| f =~ /(monkeybars-)(.+).jar$/}.first
end

#case Monkeybars::Resolver.run_location
#when Monkeybars::Resolver::IN_FILE_SYSTEM
#  add_to_classpath '../lib/java/monkeybars-1.0.4.jar'
#end

require 'monkeybars'
require 'application_controller'
require 'application_view'

# End of Monkeybars requires
#===============================================================================
#
# Add your own application-wide libraries below.  To include jars, append to
# $CLASSPATH, or use add_to_classpath, for example:
# 
# $CLASSPATH << File.expand_path(File.dirname(__FILE__) + "/../lib/java/swing-layout-1.0.3.jar")
#
# is equivalent to
#
# add_to_classpath "../lib/java/swing-layout-1.0.3.jar"
#
# There is also a helper for adding to your load path and avoiding issues with file: being
# appended to the load path (useful for JRuby libs that need your jar directory on
# the load path).
#
# add_to_load_path "../lib/java"

case Monkeybars::Resolver.run_location
when Monkeybars::Resolver::IN_FILE_SYSTEM

  # Hmmm In netbeans it's file system but we run from build/classes so needs ../..
  # but from say rake we run truly from root so need to find depth
  base = File.expand_path(File.dirname(__FILE__))

  depth = File.exists?( base + '/../../src') ? '../..' : '..'

  ADAM_ROOT_PATH = File.expand_path( File.join(base, depth) )
  ADAM_LIB_PATH  = File.expand_path( File.join(base, depth, 'lib') )
  ADAM_SRC_PATH  = File.expand_path( File.join(base, depth, 'src') )
  
  #puts "DEBUG: Add Main gem area to load PATH #{ADAM_LIB_PATH}/ruby"
  #$:.unshift("#{ADAM_LIB_PATH}/ruby")

  # These appear to be served out of the build/classes area

  # 
  # Add 3rd party gems in lib/ruby to LOAD_PATH
  # The key is that many gems make assumptions about the load path. 
  # In particular, they assume that gemname/lib is there, but not the subdirectories. 
  # Gems often use a gem root-level file to manage the loading of additional files; 
  # messing up the expected load path will bring sadness and pain.
  
  Dir.entries("#{ADAM_LIB_PATH}/ruby").each do |gemname|
    
    next if(gemname == '.' || gemname == '..')
    gem_load_path = File.join('ruby', gemname, 'lib')
    #puts "DEBUG: Add gem #{gem_load_path}"
    $:.unshift("#{ADAM_LIB_PATH}/ruby/#{gemname}/lib")
  end

  $CLASSPATH << File.join(ADAM_SRC_PATH, 'lib')
  $CLASSPATH << File.join(ADAM_SRC_PATH, 'lib', 'autotelik')
  
  # 3rd party jars
   
  ADAM_JAVA_LIB_PATH = File.join(ADAM_LIB_PATH, 'java')
  
  $:.unshift(ADAM_JAVA_LIB_PATH)
  $CLASSPATH << ADAM_JAVA_LIB_PATH
    
  Dir.glob( File.join(ADAM_JAVA_LIB_PATH, '*.jar') ).each do |f| 
    next unless(File.file?(f))
    puts "DEBUG: Add JAR #{f}"
    #$CLASSPATH << f 
    #require File.basename(f)
  end
    

when Monkeybars::Resolver::IN_JAR_FILE
  # TODO - Still only runs out of Netbeans (F6)
  #puts "DEBUG IN JAR FILE"
  add_to_load_path "activerecord/lib"
  
   # Files to be added only when run from inside a jar file something like...
	 add_to_classpath "../build/classes" #location where Netbeans places compiled .class files
	 add_to_classpath "../lib/swing-layout-1.0.3.jar" #needed to run layouts created using "Free Design"
end

