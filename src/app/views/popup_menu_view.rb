# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
include_class javax.swing.JMenuItem
include_class javax.swing.JPopupMenu

class PopupMenuView < ApplicationView
  set_java_class 'javax.swing.JPopupMenu'

  define_signal :name => :show_items,  :handler => :show_items

  def show_items(model, transfer)
    #puts "IN : PopupMenuView show_items"
    items          = transfer[:items]
    actionListener = transfer[:actionListener]
    event          = transfer[:event]
    items.each do |str|
      if(str.class == String)
        item = javax.swing.JMenuItem.new(str)
        @main_view_component.add( item )
        item.addActionListener(actionListener)
      else
        @main_view_component.send(str)
      end
    end

    @main_view_component.show( event.getComponent, event.getX, event.getY)
  end
end