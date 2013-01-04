# Copyright:: (c) Kubris & Autotelik Media Ltd 2009
# Author ::   Tom Statter
# Date ::     May 2009
# License::   MIT ?
#
require 'menu_bases'

java_import java.awt.event.InputEvent

class CalypsoServicesMenuView < ApplicationView

 include MenuView

 def load_menu( model, transfer )
    connections = transfer[:connections] || (raise ArgumentError, "No connections supplied")
    listeners   = transfer[:listeners]

    @main_view_component = javax.swing.JMenu.new("Calypso")

    newCalypsoItem = javax.swing.JMenuItem.new

    newCalypsoItem.setAccelerator(javax.swing.KeyStroke.getKeyStroke(java.awt.event.KeyEvent::VK_N, java.awt.event.InputEvent::ALT_MASK))
    newCalypsoItem.setText("New")
    @main_view_component.add(newCalypsoItem)

    connect_menu = javax.swing.JMenu.new()
    connect_menu.setText("Connect")
    @main_view_component.add(connect_menu)

    edit_connections_menu = javax.swing.JMenu.new()
    edit_connections_menu.setText("Edit")
    @main_view_component.add(edit_connections_menu)

    connections.each do |str|
      if(str.class == String)
        item = javax.swing.JMenuItem.new(str)
        connect_menu.add( item )
        listeners.each {|l| item.addActionListener(l) }
      end
    end
  end
end