# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
class Transform < ActiveRecord::Base
	
  belongs_to  :asset
  belongs_to  :functor
  belongs_to  :system

  belongs_to  :source_system, :class_name => :system, :foreign_key => 'source_system_id'
  belongs_to  :target_system, :class_name => :system, :foreign_key => 'target_system_id'

  #type and id of object that is to be transformed   
  belongs_to  :transformable, :polymorphic => true
        
end
