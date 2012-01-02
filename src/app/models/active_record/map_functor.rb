# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
# Notes on STI
#
# Rails doesn’t set the [:type] field for the base class in Single Table Inheritance.
# Only subclasses of the base class have the type field filled in.
#
# Your controllers may not see your STI subclasses unless you
# include the following in your controller files:
#
#require_dependency 'model'
#...where ‘model’ is the name of the parent class.

class MapFunction < ActiveRecord::Base

  serialize :parameters

  def to_label
    return functor unless functor.empty?
    return type
  end

  # The interface - no 'virtual' in Ruby so can only raise error ?

  def apply(subject, output_xml, input_xml)
    raise "Error - Base MapFunction apply called"
  end

end