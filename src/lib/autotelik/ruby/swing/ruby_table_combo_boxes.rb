# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
# Classes to support embedding a JComboBox within a JTable
# 
# Note include_class followed by include in class definition - is equivalent to 'implements'

include_class javax.swing.table.TableCellRenderer
include_class java.awt.Point
include_class java.awt.event.MouseListener
include_class java.awt.event.ActionEvent

class RubyTableComboBoxRenderer
  include TableCellRenderer
  
  def initialize(renderer)
    @defaultRenderer = renderer
    #puts "OUT RubyTableComboBoxRenderer : initialize"
  end

  def getTableCellRendererComponent(table, value,isSelected,hasFocus,row, column)
    if(value.is_a? Component)
      return value
    else
      return @defaultRenderer.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column)
    end
  end
end

# The ComboBox in a table will not receive events. We must implement our own
# MouseListener on the Table, determine when a ComboBox has been clicked
# and then forward onto the usual
#
class JTableComboBoxMouseListener
 # include_class javax.swing.SwingUtilities
  include MouseListener
  
  attr_reader :table

  def initialize(table)
    @table = table
  end

  def mouseClicked(e)
    forwardEventToComboBox(e)
  end

  def mousePressed(e) end

  alias_method :mouseEntered,  :mousePressed
  alias_method :mouseExited,   :mousePressed
  alias_method :mouseReleased, :mousePressed

  # Forward any relevent mouse events to the actual ComboBox
  #
  def forwardEventToComboBox(me)
    puts "IN JTableComboBoxMouseListener"
    click = Point.new(me.getX(), me.getY())
    column = @table.columnAtPoint(click)
    row = @table.rowAtPoint(click)

    return if(row >= @table.getRowCount || row < 0 || column >= @table.getColumnCount || column < 0)

    combo_box = @table.getValueAt(row, column)

    return unless(combo_box.is_a? JComboBox)

    combo_box_event = ActionEvent.new(combo_box, ActionEvent::ACTION_PERFORMED, combo_box.getActionCommand)

    ComboBox.fireActionPerformed(combo_box_event)
  end

end