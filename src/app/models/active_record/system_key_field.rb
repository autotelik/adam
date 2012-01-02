# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Dec 2008
# License::   MIT ?
#
=begin
 SYSTEM defines an incoming and/or outgoing system for processing or representing data

 This class defines the key fields required to map to or from a particular system

=end

class SystemKeyField < ActiveRecord::Base

  belongs_to	:system
  belongs_to	:basic_type

  def to_s
    self.field
  end

end