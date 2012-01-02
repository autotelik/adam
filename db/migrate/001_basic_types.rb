class BasicTypes < ActiveRecord::Migration
  
  # Notes on associations
  # Foo model belongs_to :bar if the foo table has a bar_id foreign key column.
	
  def self.up
    	
    create_table :basic_types, :force => true  do |a|
      a.string   :name, :limit => 128, :null => false
      a.string   :name_space, :limit => 90			
      a.string   :base, :default=> nil
      a.string   :use,  :default=>"required"
      a.boolean	 :abstract, :default => false
      a.text   	 :meta
    end
  end

  create_table :languages, :force => true  do |l|
    l.string  :name,  :null => false
    l.string  :version, :limit => 24
    l.timestamps
	end

  def self.down
    drop_table :basic_types
    drop_table :languages
  end
  
end
