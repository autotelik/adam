# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
class ConversionOutputView < ApplicationView

  set_java_class 'app.java.dialogs.ConversionOutputDialog'
  
  define_signal :name => :new_output_text,  :handler => :new_output_text

  def new_output_text(model, transfer)
    #puts "IN ConversionOutputView : new_output_text"
    outputTextPane.text = transfer[:output_text].to_s
  end
  
end