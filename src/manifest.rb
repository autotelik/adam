Dir.glob(File.expand_path(File.dirname(__FILE__) + "/**/*").gsub('%20', ' ')).each do |directory|
  # File.directory? is broken in current JRuby for dirs inside jars
  # http://jira.codehaus.org/browse/JRUBY-2289
  $LOAD_PATH << directory unless directory =~ /\.\w+$/
end
# Some JRuby $LOAD_PATH path bugs to check if you're having trouble:
# http://jira.codehaus.org/browse/JRUBY-2518 - Dir.glob and Dir[] doesn't work
#                                              for starting in a dir in a jar
#                                              (such as Active-Record migrations)
# http://jira.codehaus.org/browse/JRUBY-3247 - Compiled Ruby classes produce
#                                              word substitutes for characters
#                                              like - and . (to minus and dot).
#                                              This is problematic with gems
#                                              like ActiveSupport and Prawn

#===============================================================================
# Monkeybars requires, this pulls in the requisite libraries needed for
# Monkeybars to operate.

require 'resolver'

case Monkeybars::Resolver.run_location
when Monkeybars::Resolver::IN_FILE_SYSTEM
  add_to_classpath '../lib/java/monkeybars-1.0.4.jar'
end

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
  ADAM_SRC_PATH  = File.expand_path( File.join(base, depth, 'src') )

  add_to_load_path( "#{depth}/lib/ruby" )

  # 3rd party in vendor

  Dir.entries("#{ADAM_SRC_PATH}/vendor").each { |plugin| $:.unshift("vendor/#{plugin}/lib") }

  # 3rd party jars

  ['poi-3.7-20101029', 'substance'].each do |jar|
    add_to_classpath "#{depth}/lib/java/#{jar}.jar"
  end

when Monkeybars::Resolver::IN_JAR_FILE
  puts "IN JAR FILE"
  # TODO - how to run from a jar !?
end

# SET LOAD PATH FOR EXTERNAL GEMS/PLUGINS STORED IN lib/ruby

$:.unshift('activemodel/lib')
$:.unshift('activerecord/lib')
$:.unshift('activesupport/lib')
$:.unshift('arel-2.0.10/lib')
$:.unshift('hpricot-0.8.4-java/lib')
$:.unshift('i18n/lib')
