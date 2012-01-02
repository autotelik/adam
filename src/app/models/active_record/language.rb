# Copyright:: (c) Kubris & Autotelik Media Ltd 2009
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#
=begin
 Language contains details of a software development language or API
=end

class Language < ActiveRecord::Base

  has_many :snippets
  
  validates_uniqueness_of :name

  # TODO - how are attributes managed self.type works but not @type
  def to_s
    self.name
  end
  
end
