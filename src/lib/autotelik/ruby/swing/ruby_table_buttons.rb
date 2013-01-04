# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
# Classes to support embedding a JButton within a JTable
# 
# Note java_import followed by include in class definition - is equivalent to 'implements'

java_import javax.swing.table.TableCellRenderer
java_import java.awt.Point
java_import java.awt.event.MouseListener
java_import java.awt.event.ActionEvent

class RubyTableButtonRenderer
  include TableCellRenderer
  
  def initialize(renderer)
    @defaultRenderer = renderer
    #puts "OUT RubyTableButtonRenderer : initialize"
  end

  def getTableCellRendererComponent(table, value,isSelected,hasFocus,row, column)
    if(value.is_a? Component)
      return value
    else
      return @defaultRenderer.getTableCellRendererComponent(table, value, isSelected, hasFocus, row, column)
    end
  end
end

# The Button in a table will not receive events. We must implement our own
# MouseListener on the Table, determine when a button has been clicked
# and then forward onto the usual
#
class JTableButtonMouseListener
  java_import javax.swing.SwingUtilities
  
  include MouseListener
  
  attr_reader :table

  def initialize(table)
    raise ArgumentError, "JTableButtonMouseListener requires argument of type JTable" unless table.is_a? JTable
    @table = table
    @table.addMouseListener(self)
  end

  def mouseClicked(e)
    forwardEventToButton(e)
  end

  def mousePressed(e) end

  alias_method :mouseEntered,  :mousePressed
  alias_method :mouseExited,   :mousePressed
  alias_method :mouseReleased, :mousePressed

  # Forward any relevent mouse events to the actual Button
  #
  def forwardEventToButton(me)
    puts "IN JTableButtonMouseListener"
    click = Point.new(me.getX(), me.getY())
    column = @table.columnAtPoint(click)
    row = @table.rowAtPoint(click)

    return if(row >= @table.getRowCount || row < 0 || column >= @table.getColumnCount || column < 0)

    button = @table.getValueAt(row, column)

    return unless(button.is_a? JButton)

    button_event = ActionEvent.new(button, ActionEvent::ACTION_PERFORMED, button.getActionCommand)

    button.fireActionPerformed(button_event)
  end

end