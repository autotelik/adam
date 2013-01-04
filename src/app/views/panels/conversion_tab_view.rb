# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
require 'ruby_conversion_table'

java_import java.awt.event.ActionListener

class ConversionTabView < ApplicationView

  set_java_class 'app.java.panels.ConversionsTabPanel'

  # The Sub View in which we can create or edit a Conversion
  # ** Note ** :sub_view name (:conversion_tab) must match controller's add_nested_controller name
  # Need for stubs looks like MB bug, should be able to specify nil if no init code required
  nest :sub_view => :conversion_tab, :using => [:stub1, :stub2]

  def stub1(nested_view, nested_component, model, transfer)
  end

  def stub2(nested_view, nested_component, model, transfer)
  end

  # N.B Direction of conversion methods :using => [:from_model, :to_model]
  map :view => "conversionsJXTable.buttons",        :model => :run_buttons,    :using => [nil, :default]
  map :view => "conversionsJXTable.getSelectedRow", :model => :selected_node
  map :view => "conversionsJXTable.model.nodes",    :model => :nodes,          :using => [nil, :default]

  @@TAB_NAME = "Conversions Editor"
  def self.tab_name
    @@TAB_NAME
  end

  def load
    #puts "In ConversionsTabView - load"
    conversionsScrollPane.setViewportView nil

    # Swap out the Java JTable placeholder (via netbeans) for our JRuby version
    field = get_field('conversionsJXTable')
   # field.set_value(@main_view_component, RubyConversionTable.new())
#
    #conversionsScrollPane.setViewportView(conversionsJXTable)

    puts "OUT ConversionsTabView - load"
  end
  # Only bother with updating our view/model if we are current Tab.

  define_signal :name => :workTabPane_state_changed,  :handler => :workTabPane_state_changed
 
  def workTabPane_state_changed(model, transfer) 
  
    if(transfer[:working_tab_name] == @@TAB_NAME)
      puts "In ConversionsTabView - workTabPane_state_changed"
      conversionsJXTable.model.populate( true ) # force reload of conversions from DB
    end
  end

  define_signal :name => :populate,  :handler => :populate

  def populate(model, transfer) 
    conversionsJXTable.model.populate( true ) # force reload of conversions from DB
  end
end