# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Dec 2008
# License::   MIT ?
#
=begin
 SYSTEM defines an incoming and/or outgoing system for processing or representing data

 The 'import' task acts to transform an Asset's representation
 in that System, into an ADAM representation, stored ultimately in the DB.

 The 'export' view provides transformation services from ADAM representations of a asset
 to the representation required for this System. e.g save a file in Excel xls format.

 The 'spawn' task  attempts to spawn an underlying instance/process of the system,
 populating with an ADAM representations of a asset. e.g start the Excel application 

 The class asset_schema has a strong association with System classes, it provides
 the means to filter an Asset's nodes for a particular system view. 
 Different nodes may be required for different Systems, and asset_schema links between that
 set of nodes and a System.
=end

class System < ActiveRecord::Base
	
  has_many		:asset_schemas
  has_many		:viewables, :through => :asset_schemas

  has_many    :key_fields, :class_name => 'SystemKeyField'

  # From this system to another
  has_many    :subject_transforms, :class_name => 'Transform', :foreign_key => 'source_system_id'

  # To this system from another
  has_many    :object_transforms, :class_name => 'Transform', :foreign_key => 'target_system_id'


  validates_uniqueness_of :type

  # TODO - how are attributes managed self.type works but not @type
  def to_s
    self.type
  end
  
  # Parse an input stream and convert to this systems format
  def import( file, project, input, options = {})
    # TODO - is there a default .. XML .. ??  - can't think of suitable one !
    # - if no suitable default exists raise error cos no abstract in Ruby
  end
	
  # Create an output stream and populate with data from the project
  def export( asset, filename, options = {})
    # TODO - is there a default .. XML .. ??  - can't think of suitable one !
    # - if no suitable default exists raise error cos no abstract in Ruby
  end
  
  # Spawn an application, and populate with data from the project
  def spawn( project, data, options = {})
    # TODO - is there a default .. XML .. ??  - can't think of suitable one !
    # - if no suitable default exists raise error cos no abstract in Ruby
  end
  
  # JRUBY way ??
  #  def self.get_subclasses(klass)
  #     ObjectSpace.enum_for(:each_object, class << klass; self; end).to_a
  #  end

  # Provide ability for client to query all 'Systems' currently available
  
  def self.inherited(subclass) 
    if superclass.respond_to? :inherited 
      superclass.inherited(subclass) 
    end 

    @subclasses ||= [] 
    @subclasses << subclass 
  end 

  def self.subclasses 
    @subclasses 
  end 
end
