# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Dec 2008
# License::   MIT ?
#
#java_import javax.swing.JTable
#java_import org.jdesktop.swingx.treetable.*
java_import org.jdesktop.swingx.treetable.DefaultTreeTableModel

require 'system'
require 'schemable'

class RubySchemaTable <  org.jdesktop.swingx.JXTreeTable

  java_import org.jdesktop.swingx.treetable.DefaultMutableTreeTableNode
  java_import org.jdesktop.swingx.renderer.DefaultTreeRenderer

  #java_import org.jvnet.substance.SubstanceDefaultTableCellRenderer#.BooleanRenderer

  attr_accessor :start_data_index

  # Table has a number of info columns followed by the editable data colums (check boxes)
  # Args : start_data_index is the first editable data column index

  def initialize()

    tree_model = RubySchemaTableModel.new()

    @start_data_index  = tree_model.start_data_index

    super( tree_model )
    setTreeCellRenderer(DefaultTreeRenderer.new())

    setColumnControlVisible(true);

  end

  # Should always access the model via : getTreeTableModel
  def model
    return getTreeTableModel
  end

  def create_tree( parent_node, composer )
    raise ArgumentError, "Parent Node must be of type DefaultMutableTreeTableNode" unless  parent_node.is_a? DefaultMutableTreeTableNode
     node = DefaultMutableTreeTableNode.new(composer)
     parent_node.add(node)
     composer.children.each do |c|
      #next if( c.name.nil? or c.name.empty? ) #TODO - support different composers Anonymous/Group etc
      create_tree(node, c) # descend children of children, down whole tree
    end
  end

  # Row 0 contains details of the ASSET

  def getCellEditor(row, column)
    if(row > 0 && column >= @start_data_index )
      return getDefaultEditor(java.lang.Boolean)
    else
      return getDefaultEditor(getColumnClass(column))
    end
  end

  def getCellRenderer( row, column)
    if(row > 0 && column >= @start_data_index )
      return getDefaultRenderer(java.lang.Boolean)
    else
      return getDefaultRenderer(getColumnClass(column))
    end
  end
end   # END TABLE


# TODO - remove hard coded row/column usage and assign dynamically based on the columsn 
# representing Output Systems

class RubySchemaTableModel < org.jdesktop.swingx.treetable.DefaultTreeTableModel 
  
  java_import org.jdesktop.swingx.treetable.DefaultMutableTreeTableNode
    
  attr_accessor :start_data_index
 
  def initialize()
    super()
    
    @schema_classes        = Schemable::all_schemas( true )
    
    @schema_names          = Schemable::schema_names #@schema_classes.collect { |s| s.class.name.sub( 'System', '') } # To display

    @schema_column_headers = ["Component"] + @schema_names
    @start_data_index      = (@schema_column_headers.size - @schema_names.size)

    # The column headings as displayed to user
    set_column_identifiers( java.util.ArrayList.new(@schema_column_headers) )
       
  end
  
  # Return associated schema interegation method (pass in System for supplied column)
  # e.g xml? => composer.send( :xml? )
  def schema_method( column )
    Schemable::schema_method( schema_class(column) )
  end
  
  # Return associated system for supplied column
  # e.g xml? => composer.send( :xml? )
  def schema_class( column )
    @schema_classes[column - @start_data_index] 
  end
  
  # We don't want the Tree element to be editable in the schema editor - only the Table (data columns)
    
  def isCellEditable(node, column)
    #puts "CELL #{node}:#{column} IS EDITABLE [#{(column >= @start_data_index )}]"
    return (column >= @start_data_index )
  end

  def setValueAt(value, node, column) 

    if(node.is_a?(DefaultMutableTreeTableNode) )
      o = node.getUserObject()
      if( o.is_a?(Composer) )
        # Look up the Composer's schema definition for the selected system column
        s = o.asset_schemas.find( :first, :conditions => ["system_id = ?", schema_class(column).id] )
       
        if(s.nil? && (value == true) )
         # puts "RubySchemaTableModel - Setting asset schema for [#{o.name}] at [#{column}] TO [#{value}]"
          s = o.asset_schemas.create( :system => schema_class(column) )
          if(s.errors.size > 0)
            # TODO - error dialogs
            s.errors.each_full {|msg| puts "ERROR #{msg}" }
          else
            o.systems(true) # force reload
          end
        elsif(s && (value == false) )
          puts "Setting asset schema for [#{s.inspect}] at [#{column}] TO [#{value}]"
          s.destroy 
          o.systems(true) # force reload
        end
      end
    end
  end
  
  # TODO - INVESTIGATE - This seems to get called multiple times for same node/column
  # during construction/refresh - where I would expect a single call 
  
  def getValueAt(node, column)
   
    if(node.is_a?(DefaultMutableTreeTableNode) )
      o = node.getUserObject()
      # puts "getValueAt #{o.class} #{o} @ [#{column}]"
      if(o.nil?)
        return String.new()
      elsif(o.is_a?(String) && (column < @start_data_index))
        return o
      elsif(o.is_a?(Composer) ) 
        if (column >= @start_data_index )
          func = schema_method(column)
          #puts "Does Composer #{o.name} @ [#{column}] - support #{func}"
          return o.send(func) if o.respond_to? func 
        else
          return o.name
        end
      end
    end
    nil
  end
  
end   # END MODEL CLASS
