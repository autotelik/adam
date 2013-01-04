# Copyright:: (c) Autotelik Media Ltd 2013
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT
#
java_import org.jdesktop.swingx.JXTable
java_import javax.swing.table.DefaultTableModel

class RubyTable < org.jdesktop.swingx.JXTable
  def initialize( )
    super()
    setColumnControlVisible(true)
  end
end


class RubyTableModel < javax.swing.table.DefaultTableModel # AbstractTableModel
  java_import java.util.Vector
  
  attr_reader   :columns, :rows
  attr_accessor :column_identifiers
 
  def initialize(column_headers, options = {} )
    #puts "IN RubyTableModel : initialize"
    @rows               = options[:row_count] || 0
    @columns            = column_headers.size
    @column_identifiers = column_headers
    
    if options[:row_count]
      super( Vector.new(column_headers), options[:row_count])
    else
      super( Vector.new(column_headers))
    end
    #puts "OUT RubyTableModel : initialize"
  end

  def getColumnIdentifiers()
    @column_identifiers
  end

  alias_method :get_column_identifiers, :getColumnIdentifiers

  # Removes the specified column from the table and the associated
  # cell data from the table model.

#  def removeColumnAndData( table,  vColIndex)
#
#    col = getColumn(vColIndex)
#    columnModelIndex = col.getModelIndex
#    data = getDataVector
#    colIds = getColumnIdentifiers
#
#    #        # Remove the column from the table
#    #        table.removeColumn(col);
#    #
#    #        # Remove the column header from the table model
#    #        colIds.removeElementAt(columnModelIndex);
#    #
#    #        # Remove the column data
#    #        for (int r=0; r<data.size(); r++) {
#    #            Vector row = (Vector)data.get(r);
#    #            row.removeElementAt(columnModelIndex);
#    #        }
#    #        model.setDataVector(data, colIds);
#    #
#    #        # Correct the model indices in the TableColumn objects
#    #        # by decrementing those indices that follow the deleted column
#    #        Enumeration enum = table.getColumnModel().getColumns();
#    #        for (; enum.hasMoreElements(); ) {
#    #            TableColumn c = (TableColumn)enum.nextElement();
#    #            if (c.getModelIndex() >= columnModelIndex) {
#    #                c.setModelIndex(c.getModelIndex()-1);
#    #            }
#    #        }
#    #        model.fireTableStructureChanged();
#  end


end