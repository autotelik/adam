# Copyright:: (c) Tom Statter at Autotelik Media Ltd 2011
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   TBD
#
class MappingSchema < ActiveRecord::Base
  
  belongs_to  :asset
  belongs_to  :source, :class_name => 'System', :foreign_key => 'source_id'

  has_many    :composer_mappings

  validates_presence_of 	:reference
  validates_uniqueness_of :reference
  validates_length_of 		:reference, :maximum => 64
  #validates_format_of 		:reference, :with => /^[A-Za-z0-9\-]*$/

  def to_s
    self.reference
  end

end