# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
class Project < ActiveRecord::Base

  has_many 	:assets, :dependent => :destroy, :order => :name

  validates_presence_of 	:name, :description, :identifier
  validates_uniqueness_of :name, :identifier
  validates_length_of 		:name, :maximum => 30
  validates_length_of 		:description, :maximum => 255
  validates_length_of 		:identifier, :in => 3..20
  validates_format_of 		:identifier, :with => /^[a-z0-9\-]*$/
  
  
end
