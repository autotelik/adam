# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
require 'ruby_schema_table'
require 'ruby_mouse_listener'

#include_class java.awt.event.ActionListener

class SchemaTabView < ApplicationView

  include_class org.jdesktop.swingx.treetable.DefaultTreeTableModel
  include_class org.jdesktop.swingx.treetable.DefaultMutableTreeTableNode
  include_class java.awt.event.MouseAdapter

  set_java_class 'app.java.panels.SchemasTabPanel'

  # The Sub View in which we can create or edit Schemas
  # ** Note ** :sub_view name (:schemas_tab) must match controller's add_nested_controller name
  # Need for stubs looks like MB bug, should be able to specify nil if no init code required
  nest :sub_view => :schemas_tab, :using => [:stub1, :stub2]

  def stub1(nested_view, nested_component, model, transfer)
  end

  def stub2(nested_view, nested_component, model, transfer)
  end

  @@TAB_NAME = "Schemas Editor"
  def self.tab_name
    @@TAB_NAME
  end
  
  # Only bother with updating our view/model if we are current Tab.

  define_signal :name => :workTabPane_state_changed,  :handler => :workTabPane_state_changed
 
  def workTabPane_state_changed(model, transfer) 
  
    if(transfer[:working_tab_name] == @@TAB_NAME)
      puts "IN SCHEMAS : workTabPane_state_changed"
      schemasScrollPane.setViewportView nil

      # Swap out the Java JXtreeTable netbeans placeholder for our JRuby version
      field = get_field('schemasTreeTable')
      field.set_value(@main_view_component, RubySchemaTable.new())

      asset = transfer[:asset]

      if( asset && asset.root )
        ttroot = DefaultMutableTreeTableNode.new(asset)

        # Create the Tree from the set of Composers starting with the Asset's root Composer
        #
        schemasTreeTable.create_tree(ttroot, asset.root)

        schemasTreeTable.model.setRoot ttroot
      end

      schemasTreeTable.setRootVisible(true)
      schemasTreeTable.setShowGrid(true)
      schemasTreeTable.expandAll()

      header = schemasTreeTable.getTableHeader
      puts "GOT HEADER"
      
      header.addMouseListener( transfer[:headerListener] )

      schemasScrollPane.setViewportView(schemasTreeTable)
      puts "OUT SCHEMAS : workTabPane_state_changed"
    end
  end
end