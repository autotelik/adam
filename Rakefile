# Copyright:: Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     July 2011
# License::   
#
require 'rbconfig'
require 'java'

require 'rawr'
require 'rake'
require 'rake/testtask'

$LOAD_PATH << File.join(File.expand_path(File.dirname(__FILE__)), 'src')

# Main is used to fire up all the GUI aspects so just include manifest/boot

require 'manifest'
require 'boot'

Dir.glob("tasks/**/*.rake").each do |rake_file|
  load File.expand_path(File.dirname(__FILE__) + "/" + rake_file)
end
