# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
=begin
	Schema - The basis for the output representation of an Asset.
	
	Joins asset's nodes to an output system.  Any node type is supported via 'viewable'
=end

class AssetSchema < ActiveRecord::Base
	
  belongs_to :system
  belongs_to :asset
	
  belongs_to :property
	
  belongs_to :viewable, :polymorphic => true
	
  # If no Asset provided explicitly, we can assume it's same as the viewable element
	
  def before_create
    if self.asset.nil? && self.viewable
      self.asset = self.viewable.asset if self.viewable.respond_to? :asset
    end
  end
	
end
