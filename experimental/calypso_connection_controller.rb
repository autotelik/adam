# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Mar 2009
# License::   MIT ?

class CalypsoConnectionController < ApplicationController
  
  set_view  'CalypsoConnectionView'
  set_model 'CalypsoConnection'

  set_close_action :close
 
  def close_button_action_performed
    close
  end  
end
