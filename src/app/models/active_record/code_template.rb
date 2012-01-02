# Copyright:: (c) Kubris & Autotelik Media Ltd 2009
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#
=begin
 CodeTemplate contains software development templates for teh use as the basis for
 software, scripts and test harnesses
=end

class CodeTemplate < ActiveRecord::Base
	
  validates_uniqueness_of :name

  # TODO - how are attributes managed self.type works but not @type
  def to_s
    self.code
  end
  
end
