class Transforms < ActiveRecord::Migration
  
  def self.up
  	

    # Link a mapping function to the actual conversion of a stored component :
    # Polymorphic so can attach a mapping to any element of the Repository

    create_table :transforms, :force => true  do |tr|
				tr.integer     :asset_id, :null => false
				tr.integer     :position
				tr.integer     :functor_id, :null => false
				tr.integer     :source_system_id, :null => false
				tr.integer     :system_id

				#type and id of object that is to be transformed
				tr.references  :transformable, :polymorphic => true, :null => false
				tr.timestamps
		end


		# We use single table inheritance for different functor classes
		# enabling support for different transforms such as send, XSLT, eval, one-to-one etc
    # Stores mappings, from one representation to another system's
		 
		create_table :functors, :force => true do |mf|
      mf.string  :type,  :null => false            # STI - Base MapFunction
			mf.string  :method
			mf.string  :argument
			mf.timestamps
		end
		

    add_index(:transforms, :asset_id)
    add_index(:transforms, :functor_id)
    add_index(:transforms, :system_id)
    add_index(:transforms, :transformable_id)
    add_index(:transforms, :transformable_type)
    			 		    
  end

  def self.down
    drop_table :functors
    drop_table :transforms
  end
  
end
