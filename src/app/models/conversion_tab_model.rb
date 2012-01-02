# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
class ConversionTabModel
  
  attr_accessor :run_buttons, :selected_node, :nodes

  def initialize
    @run_buttons = []
    @nodes = []
    @selected_node = -1
  end

  # Call run on the current Conversion instance
  def run_current_conversion
    return if(@selected_node < 0 || @selected_node >= @nodes.size)
    #puts "ConversionTabModel : Run Conversion #{@current_node} #{@nodes.inspect}"
    @nodes[@selected_node].run
  end

  def current_node
    return nil if(@selected_node < 0 || @selected_node >= @nodes.size)
    @nodes[@selected_node]
  end

  def delete_current_node
    return if(@selected_node < 0 || @selected_node >= @nodes.size)
    @nodes[@selected_node].destroy
    @nodes.delete_at @selected_node
    @nodes.size > 1 ? @selected_node = 0: @selected_node = -1
  end

end