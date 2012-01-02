# Copyright:: Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     July 2011
# License::
# 
# This file suppports the whole testing process via rake. Enables fixtures, contains the base tasks
# such as setting up environment, and creates individually runnable tasks for each test suite
# method that also show up when calling rake -T

require 'active_support/inflector'
require 'active_record/fixtures'
  
# Need to tell active support where to find the fixture files
# Upgrade to rails 2.3.2 has broken this
# 
#ActiveRecord::TestCase.fixture_path = "test/fixtures"
 
# Now create rake tasks for unit tests, both whole suite and individual tests
# 
Dir.glob("test/unit/*.rb").each do |unit|
  # Create tasks for the individual tests (methods)
  meth_tests = []
  File.open(unit, 'r') do |f|
    f.each do |line|
      meth_tests << line.sub(/def\s+/, '').strip if line =~ /def test_/
    end
  end
  
  t = unit.gsub('.rb', '').split("/").last
  klass = ActiveSupport::Inflector.classify(t)

  desc 'run complete suite'
  task "#{t}".intern => :setup do
    require "#{unit}"
    require 'test/unit/ui/console/testrunner'
    suite = eval( "TC_#{klass}.new" )
    Test::Unit::UI::Console::TestRunner.run(suite)
  end

  # TODO - ADD NAMESPACES - what if two methods from different test classes share name
  #
  meth_tests.each do |m|  
    desc "run individual test #{m}"
    task "#{m}".intern => :setup do
      require "#{unit}"
      require 'test/unit/ui/console/testrunner'
      suite = eval("TC_#{klass}.new(:#{m})")
      Test::Unit::UI::Console::TestRunner.run(suite)
    end
  end
end
