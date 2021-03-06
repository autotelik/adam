# Copyright:: (c) Autotelik Media Ltd 2013
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
require 'acts_as_versioned'

class Annotation < ActiveRecord::Base

  # assumes annotation_versions table
  acts_as_versioned

  # Defines Type and ID of any ADAM object that has Annotations
  #
  belongs_to :element, :polymorphic => true

  attr_accessible :documentation
  
end
