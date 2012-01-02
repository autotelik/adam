# Copyright:: (c) Kubris & Autotelik Media Ltd 2009
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#
=begin
 Snippet contains small snippets of reusable software development code
=end

class Snippet < ActiveRecord::Base

  belongs_to :language

  validates_uniqueness_of :name

  # TODO - how are attributes managed self.type works but not @type
  def to_s
    self.name
  end
  
end
