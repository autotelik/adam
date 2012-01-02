# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#

class SchemaTabController < ApplicationController
  set_model 'SchemaTabModel'
  set_view  'SchemaTabView'
  
  set_close_action :close

  ##################
  # FORWARDED EVENTS (from main AdamController)
  ##################
 
  def workTabPane_state_changed( main_model )
    transfer[:working_tab_index] = main_model.working_tab_index   # Set details from Main controller
    transfer[:working_tab_name]  = main_model.working_tab_name
    transfer[:asset]             = main_model.asset
    x = RubyMouseListener.new(self)
    transfer[:headerListener]    = x
    signal :workTabPane_state_changed
  end

  # User has selected a different Asset, requires exact same processing as workTabPane_state_changed
  #
  def asset_selected( main_model )
    workTabPane_state_changed( main_model )
  end

 
  # Handle Mouse events within the Table.
  # Actions depends on click count and column
  #
  def mouse_clicked(event)
    
    puts "IN schemasTreeTable_mouse_clicked : #{event.inspect}"
    puts "MOUSE #{event.class} : #{event.getClickCount} : BUTTON #{event.getButton}"

    # Double Click => EDIT
    if(event.getClickCount == 2)
      puts "edit"
      
    elsif( event.getButton == java.awt.event.MouseEvent::BUTTON3)
      
      transfer[:event] = event

      listener = PopupActionListener.new( self )

      items = ["Select All", "Clear"]

      listener.add_callback_method("Select All", :select_all_action_performed )

      listener.add_callback("Clear") do
        puts "CLEAR SCHEMA SELECTION"
      end

      pmenu = PopupMenuController.create_instance

      pmenu.open(event, items, listener )
    end
  end

  # User clicks the JXTreeTable displaying Asset's achema definitions
  #
  def schemasTreeTable_mouse_exited(event)
    puts "IN schemas_tree_table_mouse_clicked"
    puts "MOUSE #{event.class} : #{event.getClickCount} : BUTTON #{event.getButton}"
    if( event.getButton == java.awt.event.MouseEvent::BUTTON3)

    end
  end

end