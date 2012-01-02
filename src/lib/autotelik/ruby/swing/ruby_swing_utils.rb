# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
# Swing Utilities for ADAM classes and AR models

module RubySwingUtils

  # Populate a Swing Componenent that supports  addItem & setSelectedItem
  #
  def add_items( component, options = {:selected => 0} )
    items  = options[:items] || find(:all, options[:args] )
    items.each do |s| component.addItem(s) end
    selected = options[:selected] || 0
    component.setSelectedItem( items[selected] )
  end
end

class ActiveRecord::Base
  extend RubySwingUtils
end