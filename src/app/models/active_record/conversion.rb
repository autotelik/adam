# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
require 'ruby_swing_utils'

class Conversion < ActiveRecord::Base

  extend RubySwingUtils

  belongs_to  :mapping_schema

  belongs_to  :output_system, :class_name => 'System', :foreign_key => 'output_system_id'

  validates_associated :mapping_schema, :output_system

  validates_presence_of 	:data_source
  validates_length_of 		:data_source, :maximum => 1024

  # TODO - Required by Swing components, overloading toString does not seem to work ??

  def to_s
    self.mapping_schema.reference
  end

  def asset
    mapping_schema.asset
  end

  def run
    puts "IN Conversion : run - output System #{output_system.class} : #{data_source}"
    source = mapping_schema.source.class.new

    asset = mapping_schema.asset
    
    # Populate with Excel data, one for each Row of the spreadsheet
    source.populate( asset, data_source)
    # puts asset.data_store.inspect

    # Return output generated from populated asset
    output_system.generate(asset)
  end
 
end