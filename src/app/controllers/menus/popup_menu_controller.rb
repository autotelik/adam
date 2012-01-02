# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
require 'popup_menu_view'
require 'ruby_action_listener'

class PopupMenuController < ApplicationController
  set_view  'PopupMenuView'

  # Args : The event which requested the pop up and the items to show
  # in the menu
  
  def open( event, items, listener)
    #puts "IN : PopupMenuController : open"
    transfer[:event]          = event
    transfer[:items]          = items
    transfer[:actionListener] = listener
    #puts "PopupMenuController : show_items"
    signal( :show_items )
  end
end

class PopupActionListener < RubyActionListener
end