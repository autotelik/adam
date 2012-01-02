# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#
require 'ruby_action_listener'

class SnippetsMenuController < ApplicationController

  include_class java.awt.event.ActionListener
  include_class java.awt.event.ActionEvent

  set_view  'SnippetsMenuView'
  set_model 'SnippetsMenuModel'

  # Args : The event which requested the pop up and the items to show
  # in the menu
  
  def load( listeners )
    puts "IN SnippetsMenuController : open"
    model.load_snippets

    listeners.is_a?(Array) ? listeners << self : listeners = [listeners , self]

    transfer[:listeners] = listeners
    
    signal( :load_menu )
  end

  # User has selected a Snippet from the menu
  
  def actionPerformed(actionEvent)
    #puts actionEvent.getSource.getAction.snippet.code
  end

end