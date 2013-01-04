# Copyright:: Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
require 'conversion'
require 'ruby_table'
require 'mapping_helper'
require 'system_helper'

java_import javax.swing.DefaultCellEditor
java_import javax.swing.JButton
java_import javax.swing.table.TableCellRenderer
java_import javax.swing.JComboBox
java_import java.awt.event.ActionListener
java_import java.awt.event.ActionEvent

require 'ruby_table_buttons'
require 'ruby_table_combo_boxes'

class RubyConversionTable < RubyTable

  # Create a table showing available conversions from a source of raw data)
  # to the Asset (receiver of the mapped data)
  #
  # Each conversion has a specified output system for display of the mapped data
  #
  def initialize()
    #puts "IN RubyConversionTable : initialize"
    super()

    load

    #puts "OUT  RubyConversionTable : initialize"
  end

  def load()
    #puts "IN RubyConversionTable : load"
   # setModel( RubyConversionTableModel.new() )
    #getColumn(model.output_column).setCellEditor( DefaultCellEditor.new(model.system_box) )
    #default_renderer = getDefaultRenderer(javax.swing.JComboBox)
    #setDefaultRenderer(javax.swing.JComboBox, RubyTableComboBoxRenderer.new(default_renderer))

    #default_renderer = getDefaultRenderer(JButton)
   # setDefaultRenderer(JButton, RubyTableButtonRenderer.new(default_renderer))

   # addMouseListener(JTableButtonMouseListener.new(self))

    #puts "OUT  RubyConversionTable : load"
  end

  def buttons
    model.buttons
  end

  def model
    getModel
  end
end

class RubyConversionTableModel < RubyTableModel

  java_import javax.swing.DefaultCellEditor
  java_import javax.swing.JComboBox
  java_import javax.swing.SwingConstants
  
  attr_accessor :asset_box, :system_box, :buttons
  attr_reader   :control_column, :nodes, :output_column
  
  def initialize()
    #puts "IN RubyConversionTableModel : initialize"
    @output_column  = "Output System"
    @control_column = "Controls"
    @nodes          = Conversion.find :all, :include => [:mapping_schema]
    #@system_box     = JComboBox.new()

    #SystemHelper::add_items(@system_box)

    headers = ["Name", "Mapping Ref", "Asset",  "Source System", "Source Data", @output_column, @control_column]
 
    super( headers, {:row_count => @nodes.size} )

    populate
    
    #puts "OUT RubyConversionTableModel : initialize"
  end
  
  def populate( reload = false )
    puts "IN RubyConversionTableModel : populate"
    data = []
    @buttons = []

    @nodes   = Conversion.find(:all, :include => [:mapping_schema]) if reload

    @nodes.each_with_index do |conversion, i|
      cm = conversion.mapping_schema

      system = Schemable::schema_name(conversion.output_system)#JComboBox.new()

      instance_variable_set("@button#{i}", JButton.new("Run"))

      btn = instance_variable_get("@button#{i}")

      @buttons << btn
      btn.setEnabled(true)
      btn.setHorizontalTextPosition(javax.swing.SwingConstants::CENTER)
      btn.setVerticalTextPosition(javax.swing.SwingConstants::BOTTOM)

      arr = [conversion.name, cm.reference, cm.asset, cm.source, conversion.data_source, system, btn ]

      data << Vector.new(arr)
    end

    puts "SET #{data.size} CONVERSIONS IN TABLE"
    
    setDataVector(Vector.new(data), Vector.new(column_identifiers) )
    #puts "OUT RubyConversionTableModel : populate"
  end

  def isCellEditable(row, column)
    return true if(getColumnName(column) == "Data Source")
    false
  end

  def getColumnClass(column)
    #if( getColumnName(column) == @output_column)
     # return JComboBox
    #els
    if( getColumnName(column) == @control_column)
      return JButton
    else
      return super(column)  # No special model
    end
  end

end