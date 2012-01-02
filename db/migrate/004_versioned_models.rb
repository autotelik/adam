require 'annotation'

class VersionedModels < ActiveRecord::Migration
  
  def self.up

    require_dependency 'annotation'

    # create_versioned_table takes the same options hash
    # that create_table does
    Annotation.create_versioned_table

  end

  def self.down
    Annotation.drop_versioned_table
  end
  
end
