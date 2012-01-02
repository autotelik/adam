class Mappings < ActiveRecord::Migration
  
  def self.up
    
    # We use single table inheritance defining different System classes
    # where a System defines any external entity such as downstream system or output view
  	  		   
    create_table  :systems, :force => true  do |sys|
      sys.string  :type,  :null => false           
      sys.timestamps
    end

    # Defines the key fields used to map from a particular system
    # e.g ExcelSystem may have two keys => Worksheet, and Column
    # XML may have one key, XPath, CSV => Column, etc
   
    create_table  :system_key_fields, :force => true  do |keys|
      keys.integer    :system_id, :null => false
      keys.string     :field, :null => false
      keys.string     :basic_type_id, :null => true   # Optional type on field e.g 4 validation
      keys.string	    :pop_default, :default => nil
      keys.boolean	  :pop_auto_increment, :default => false
    end


    # Defines whether a particular node should be output to a particular system
    # TODO - make this per user once user auth in place
    # Foo model belongs_to :bar if the foo table has a bar_id foreign key column.

    create_table  :asset_schemas, :force => true  do |schema|
      schema.string       :name, :default => ""
      schema.integer      :asset_id, :null => false
      schema.integer      :system_id, :null => false
      #type+id of object to be included in the schema for viewing on output system   
      schema.references  	:viewable, :polymorphic => true, :null => false
      schema.integer   		:property_id		# optional properties such as default values
      schema.timestamps
    end	

    create_table :composer_types, :force => true  do |ct|
      ct.integer    :composer_id, :null => false
      #type and id of  object that has properties attached
      ct.references :klass, :polymorphic => true, :null => false
      ct.timestamps
    end

    #####################################
		# MAPPING - Transformation definitions
		######################################

    create_table :mapping_schemas, :force => true do |m|
      m.integer    :asset_id, :null => false
      m.string     :reference, :null => false
      m.integer    :source_id, :null => false
			m.timestamps
		end

    # Join parent MappingSchema to the individual nodes that make up the mapping
    
    create_table :composer_mappings, :force => true do |m|
      m.integer    :mapping_schema_id, :null => false
      # MAP *TO* THIS ITEM
      m.integer    :composer_id, :null => false  
      # *FROM* FIELD IN SYSTEM (AS IDENTIFIED BY source_id)
      m.integer    :system_key_field_id, :null => false
      m.string     :value, :null => false
			m.timestamps
		end

    # Link a mapping schema to an actual conversion

    create_table :conversions, :force => true  do |c|
        c.string      :name
        c.integer     :mapping_schema_id, :null => false
				c.string      :data_source, :null => false
				c.integer     :output_system_id, :null => false
				c.timestamps
		end

  end

  def self.down
    drop_table :systems
    drop_table :asset_schemas
    drop_table :mapping_schemas
    drop_table :composer_mappings
    drop_table :conversions
  end
  
end
