# Copyright:: Autotelik Media Ltd 2011
# Author ::   Tom Statter
# Date ::     July 2011
# License::   MIT
#
require 'basic_type'
require 'ruby_table'
require 'mapping_helper'
require 'system_helper'

java_import javax.swing.DefaultCellEditor
java_import javax.swing.JComboBox

class RubyMappingTable < RubyTable
  java_import javax.swing.DefaultCellEditor
  java_import javax.swing.DefaultListCellRenderer
  java_import javax.swing.table.DefaultTableCellRenderer
  java_import java.util.Vector
  java_import javax.swing.JComboBox
  
  # Create a mapping table for the supplied System (the source of raw data)
  # to the Asset (receiver of the mapped data)
  # Each system will have different mapping fields
  # e.g CSV => Column, Excel -> Worksheet + Column and so on.
  #
  # Each Asset has a set of nodes that can be mapped,
  # N.B this can be a sub set of all it's nodes and can be different depending on the
  # source System. This is taken care of by MappingHelper::mappable_nodes
  #
  def initialize(system, asset)
    puts "In RubyMappingTable : init : #{system}"
    raise ArgumentError, "System cannot be null" unless system

    super()

    system_change( system, asset )

    puts "OUT  RubyMappingTable : initialize"
  end


  def system_change( system, asset )
    puts "IN  RubyMappingTable : system_change"
    mappable_nodes = asset ? MappingHelper::mappable_nodes(system, asset.root) : []
    @asset_box = JComboBox.new(mappable_nodes.to_java)
    #setModel( RubyMappingTableModel.new(system, mappable_nodes) )
    #getColumn(model.fixed_map_column).setCellEditor( DefaultCellEditor.new(@asset_box) )
    puts "OUT  RubyMappingTable : system_change"
  end

  # Populate the whole table with every node and some kind of default for the mapping
  
  def populate()
    #puts "IN RubyMappingTable : populate"
    model.populate
    getColumn(model.fixed_map_column).setCellEditor( DefaultCellEditor.new(@asset_box) )
    #puts "OUT RubyMappingTable : populate"
  end

  def populate_from_existing( reference )
    # puts "IN RubyMappingTable : populate_from_existing"
    model.populate_from_existing( reference )
    getColumn(model.fixed_map_column).setCellEditor( DefaultCellEditor.new(@asset_box) )
    #puts "OUT RubyMappingTable : populate"
  end

  def model
    getModel
  end
end

class RubyMappingTableModel < RubyTableModel

  @@strtype = BasicType.find_by_name_space_and_name( 'ruby', 'String')
  @@fixtype = BasicType.find_by_name_space_and_name( 'ruby', 'FixNum')

  java_import javax.swing.DefaultCellEditor
  java_import javax.swing.JComboBox

  attr_accessor :asset_box, :system_box
  attr_reader   :fixed_map_column
  
  def initialize(system, mappable_nodes)
    puts "IN RubyMappingTableModel : initialize : SYSYTEM #{system}"
    raise ArgumentError, "Argument 1 must be non null and of type System" unless system && system.is_a?(System)
    @fixed_map_column = mappable_nodes.first ? mappable_nodes.first.name : "Asset"
    @system           = system
    @mappable_nodes   = mappable_nodes
    
    headers = [@fixed_map_column] + @system.key_fields.collect {|f| f.field }
 
    # start with number of rows equal to number of possible mappings
    super( headers, {:row_count => mappable_nodes.size} )

    puts "OUT RubyMappingTableModel : initialize"
  end

  def populate_from_existing( mapping_schema )
    puts "IN RubyMappingModel : populate_from_existing"

    mappings = mapping_schema.composer_mappings

    unless(mappings.empty?)
      init = mappings.first

      @asset              = mapping_schema.asset
      @system             = init.system_key_field.system
      @fixed_map_column   = "#{@asset.name}:#{mapping_schema.reference}"
      @column_identifiers = [@fixed_map_column]
      
      @system.key_fields.each {|k| @column_identifiers << k.field }

      @mappable_nodes = []

      nodes = {}
      mappings.each do |map|
        if nodes[map.composer]
          nodes[map.composer] << map.value
        else
          @mappable_nodes << map.composer
          nodes[map.composer] = [map.composer, map.value]
        end
      end

      data = []
      nodes.each_value do |v| data << Vector.new(v) end
      setDataVector(Vector.new(data), Vector.new(column_identifiers) )
    end
    # Resets CellEditor to manage String so put back CBox
    puts "OUT RubyMappingModel : populate"

  end

  def populate()
    puts "IN RubyMappingModel : populate"
    data = []
    @mappable_nodes.each_with_index do |a, i|
      arr = [a]
      @system.key_fields.each do |f|
        if(f.basic_type == @@strtype)
          #puts "KeyField #{f} : String Type"
          arr << (f.pop_default) ?  f.pop_default : ""
        elsif(f.basic_type == @@fixtype)
          #puts "KeyField #{f}: FixNum Type"
          if(f.pop_auto_increment)
            arr << i
          else
            arr << (f.pop_default) ?  f.pop_default : 1
          end
        else
         # puts "KeyField #{f}: No Type"
          arr << ""
        end
      end
      data << Vector.new(arr)
    end
    setDataVector(Vector.new(data), Vector.new(column_identifiers) )
    # Resets CellEditor to manage String so put back CBox
    puts "OUT RubyMappingModel : populate"
  end

  def isCellEditable(row, column)
    true
  end

  def getColumnClass(column)
    if( getColumnName(column) == @fixed_map_column)
      return JComboBox.java_class
    else
      return super(column)  # No special model
    end
  end

  #  def getValueAt(row, column)
  #
  #    if(getColumnName(column) == @fixed_map_column)
  #      puts "IN RubyMappingTableModel : getValueAt : ASSET"
  #      return @asset_box.java_object
  #    end
  #    return super(row, column)  # No special model
  #  end
  #
  #  def set_value_at(value, row, column)
  #    puts "Process SET VALUE [#{value.inspect}] [#{row}:#{column}]"
  #  end

end
