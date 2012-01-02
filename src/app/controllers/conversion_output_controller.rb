# Author::    Tom Statter & Andy Griffiths
# Copyright:: (c) Kubris 2008
# License::   MIT ?
#
class ConversionOutputController < ApplicationController
  set_view  'ConversionOutputView'

  set_close_action :close

  def load(data)
    puts "IN ConversionOutputController"
    transfer[:output_text] = data
    signal :new_output_text
  end

  def save_button_action_performed
    puts "SAVE THE DATE TO FILE"
  end
  
  def close_button_action_performed
    close
  end  
end
