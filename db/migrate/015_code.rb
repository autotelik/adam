class Code < ActiveRecord::Migration
  
  def self.up
  	
    create_table :snippets, :force => true  do |s|
				s.string  :name,  :limit => 64, :null => false
        s.string  :group, :limit => 12, :null => false
        s.integer :language_id, :null => false
				s.binary  :code,  :null => false, :limit => 1000000
        s.boolean :private, :null => false, :default => false
				s.timestamps
		end
	
    add_index(:snippets, :name)

    create_table :code_templates, :force => true  do |c|
				c.string  :name,  :limit => 64, :null => false
        c.integer :language_id, :null => false
				c.binary  :code,  :null => false, :limit => 1000000
				c.timestamps
		end

    add_index(:code_templates, :name)

  end

  def self.down
    drop_table :snippets
    drop_table :code_templates
  end
  
end
