# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     May 2009
# License::   MIT ?
#
require 'ruby_action_listener'

class CalypsoServicesMenuController < ApplicationController

  java_import java.awt.event.ActionListener
  java_import java.awt.event.ActionEvent

  set_view  'CalypsoServicesMenuView'
  set_model 'CalypsoServicesMenuModel'

  # Args : The event which requested the pop up and the items to show
  # in the menu
  
  def load( listeners )
    puts "IN SnippetsMenuController : open"
   # TODO load the connections from property files in Documents Settings or USERHOME or from the DB
   #  model.load_connection
    transfer[:connections] = ['GLOBIS', 'ABSA_PROTOTYPE', 'ABSA_MASTER']

    listeners.is_a?(Array) ? listeners << self : listeners = [listeners , self]

    transfer[:listeners] = listeners
    
    signal( :load_menu )
  end

  # User has selected the menu
  
  def actionPerformed(actionEvent)

    puts "IN CalypsoServicesMenuController : actionPerformed"

    puts actionEvent.getSource
    puts actionEvent.getSource.getAction

    s = Snippet.find_by_name('ConnectToCalypso').code

    raise "Missing Code Snippet : 'ConnectToCalypso' " unless s
  end

end