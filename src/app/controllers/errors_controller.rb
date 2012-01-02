# Author::    Tom Statter & Andy Griffiths
# Copyright:: (c) Kubris 2008
# License::   MIT ?
# 
#require 'validations'

class ErrorsController < ApplicationController
  set_view  'ErrorsView'
  
  set_close_action :close

  def load(active_record)
    transfer[:active_record] = active_record
    puts "ERRORS DIALOG MODEL : #{active_record.errors.inspect}"
    signal :display
  end

  def close_button_action_performed
    close
  end

end