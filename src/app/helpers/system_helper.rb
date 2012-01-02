# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
# Utilities for the model class System

module SystemHelper

  # Map System -> [:key_fields] excluding any without key fields
  
  def self.get_key_field_map()
    System.find(:all).inject({}) { |h, s| h[s] = s.key_fields unless s.key_fields.empty?; h }
  end


  # Populate a Swing Componenent that supports  addItem & setSelectedItem
  # 
  def self.add_items( component, options = {:selected => 0} )
    systems  = options[:items] || System.find(:all, :order => :type)
    systems.each do |s|
      component.addItem(s) unless s.key_fields.empty?
    end
    selected = options[:selected] || 0
    component.setSelectedItem( systems[selected] )
  end
end