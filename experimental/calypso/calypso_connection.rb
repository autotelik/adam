# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
class CalypsoConnection
  
  attr_accessor :environment_list

  # N.B - Called by controller to create variable (@__model) but also
  # Called every time controller calls view_state, which returns
  # a new instance of the model - so keep as light as possible
  def initialize
    @environment_list = []
    puts "IN model : initialize #{self.class}"
    Dir.new(ENV['HOMEPATH']).each {|f| @environment_list << f if f.include? 'calypsouser.properties'  }
    @environment_list
    puts "OUT model - initialize"
  end
end