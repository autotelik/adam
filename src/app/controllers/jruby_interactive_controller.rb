# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#
require 'jruby_interactive_view'

class JRubyInteractiveController < ApplicationController

  set_view  'JRubyInteractiveView'
  
  set_close_action :close


  def load( parent )
    @parent = self
    @receiving = false    # Are we selectd as the work tab ?
  end

  def close
    signal :shutdown
  end

  # User has clicked on or off our Tab, sync our model with current view,
  # and create transfer for all other data required from other controller
  #
  def workTabPane_state_changed( main_model )
    if(main_model.working_tab_name == JRubyInteractiveView.tab_name)
      @receiving = true
    end
  end

  # Send the supplied jruby code to the shell.
  # If execute = true the code will be immeadiatly executed in the shell otherwise
  # it is left to user to edit code and execute at their leasure
  #
  def write_code( code, execute = false)
    transfer[:text]    = code
    transfer[:execute] = execute
    signal :send_text
  end

  def new_button_action_performed
    signal :new
  end

  def clear_button_action_performed
    signal :clear
  end

  def save_button_action_performed
    puts "save_button_action_performed"
    signal :save_text
  end

  # We listen for Snippets menu

  def actionPerformed(actionEvent)
    puts "IN JRubyInteractiveController :  RUN : #{@receiving} : #{actionEvent.getSource.getAction.respond_to?(:snippet)}"
    puts actionEvent.getSource.getAction
    puts actionEvent.getSource.getAction
    if( @receiving && actionEvent.getSource.getAction.respond_to?(:snippet) )
      transfer[:text] = actionEvent.getSource.getAction.snippet.code
      signal :send_text
    end
  end
  
end