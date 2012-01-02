# Copyright:: (c) Kubris & Autotelik Media Ltd 2009
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#
require 'menu_bases'

class SnippetsMenuView < ApplicationView

  include MenuView
  
  # Present snippets in related groups.
  # The MenuItems are expected to be of type Action
  def load_menu( model, transfer )

    puts "IN SnippetsMenuView : load #{@main_view_component.inspect}"
    listeners = transfer[:listeners]

    @main_view_component = javax.swing.JMenu.new("Snippets")

    # Each group contains array of items
    model.grouped_items.each do |g, item|
      menu = javax.swing.JMenu.new(g.to_s)
      @main_view_component.add( menu )
      
      item.each do |s|
        item = javax.swing.JMenuItem.new(s)
        listeners.each {|l| item.addActionListener(l) }
        menu.add( item )
      end
    end
  end 
end