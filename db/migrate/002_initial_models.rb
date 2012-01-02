class InitialModels < ActiveRecord::Migration
  
  def self.up
    
    # Project

    create_table :projects, :force => true do |p|
      p.string 		:name, :limit => 30, :default => "", :null => false
      p.string 		:description, :default => "", :null => false
      p.boolean 	:is_public, :default => true, :null => false
      p.string 		:identifier, :limit => 20
      p.integer		:status, :default => 1, :null => false
      p.timestamps
    end


    # Asset - Has many Composers

    create_table :assets, :force => true  do |a|
      a.integer   :project_id, :null => false
      a.string    :name, :null => false, :limit => 90
      a.string    :name_space, :limit => 90
      a.integer   :version, :null => false, :limit => 12
      a.timestamps
    end

    add_index(:assets, [:name, :version], :unique => true, :name => 'index_asset_name_and_version')
    add_index(:assets, :name)
    add_index(:assets, :version)


    # We use single table inheritance enabling different Composer classes
    # to be defined
		
    create_table :composers, :force => true  do |c|
      c.string    :name
      c.string    :type,  :null => false    # ActiveRecord uses this to store class of Composer
      c.integer   :project_id,   :null => false
      c.integer   :asset_id,   :null => false
      c.integer   :parent_id
      c.integer   :lft, :null => false
      c.integer   :rgt, :null => false
      c.integer   :lock_version, :default => 0   
      
      c.timestamps
    end
	    
    add_index(:composers, :name)
    add_index(:composers, :parent_id)
    add_index(:composers, :asset_id)
   
    create_table :composer_types, :force => true  do |ct|
      ct.integer    :composer_id, :null => false
      #type and id of  object that has properties attached
      ct.references :klass, :polymorphic => true, :null => false    			
      ct.timestamps
    end
     		
    create_table  :properties, :force => true  do |prop|
      #type and id of  object that has properties attached
      prop.references  	:element, :polymorphic => true, :null => false
      # TODO - add constraints to ensure only one is_defaults per element
      prop.boolean 	:is_default, :default => false
      prop.string   :cardinality
      prop.string 	:max , :default => '1'			# string so we can store 'unbounded'	
      prop.string 	:min , :default => '1'
      prop.integer 	:length , :default => '1'		
      prop.string   :mask
      prop.text     :free_text
      prop.timestamps
    end
	    
    create_table  :annotations, :force => true  do |a|
      #type and id of  object that has properties attached
      a.references  	:element, :polymorphic => true, :null => false
      a.text        	:documentation
      a.timestamps
    end

  end

  def self.down
    drop_table :composers
    drop_table :assets
    drop_table :projects
    drop_table :properties
    drop_table :annotations
  end
  
end
