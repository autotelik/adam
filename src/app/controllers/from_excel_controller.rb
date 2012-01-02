# Author::    Tom Statter & Andy Griffiths
# Copyright:: (c) Kubris 2008
# License::   MIT ?
# 
require 'dialog_parent'

class FromExcelController < ApplicationController
  set_view  'FromExcelView'
  set_model 'ExcelSystem'

  set_close_action :close
  
  def fileChooserActionPerformed
      puts "EXCEL OK PRESSED"
  end
 
  def file_Chooser_Cancel_action_performed
    close
  end  
end
