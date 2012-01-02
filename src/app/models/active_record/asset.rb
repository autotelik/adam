# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
require 'property'
require 'composer'
require 'acts_as_versioned'

class Asset < ActiveRecord::Base

  # Note callbacks specified before associations to ensure entire calback Q is created/called

  before_create :ensure_root_on_create

  # The DB attributes

  validates_presence_of 	:name
  validates_uniqueness_of :name, :scope => :project_id
  validates_length_of 		:name, :maximum => 64

  validates_presence_of 	:project

  # assumes asset_versions table
  acts_as_versioned

  belongs_to 	:project	
  has_many	  :asset_schemas, :dependent => :destroy
  has_one 	  :property, :as => :element, :conditions => "is_default = true"#,  :dependent => :destroy
		
  # Composers is ordered tree, with parent nodes that *destroy their own children*
  # so setting :dependent => :destroy on the :composers association will cause an error -
  # as Asset tries to destroy again, same object.
  # Hence we destroy only top level via :children association below.
  # i.e only destroy the root node
	
  has_many :composers, :order => 'parent_id ASC'

  # TODO - add validation to ensure only one root possible - must be 1-1, Asset -> Composer
  
  has_one  :root, :class_name => 'Composer', :conditions => ["parent_id is NULL"], :dependent => :destroy
  
  has_many :mapping_schemas, :dependent => :destroy

 
  # Non DB attributes, used in internal processing. The data store collects values/data
  # for each underlying node node of this Asset, from root down.
  # The value map is keyed on Composer.id, and can contain multiple rows of data
  # Usage is tightly coupled with the System classes, via their *populate* method
  #
  # ActiveRecord class - don't put extra init in initialize, use this method.
  after_initialize   :assign_data_store

  def assign_data_store
    @data_store = AssetDataStore.new( self )
  end

  # The before create filter, if no root composer provided, we create one
  # which essentially represents this asset (like a 'master' composer)
  def ensure_root_on_create
    if self.root.nil?
       self.root = Composer.new(:name => self.name, :asset => self)
    end
  end

  attr_accessor :data_store

  def value_map
    @data_store.value_map
  end

  # TODO - Required by Swing components, overloading toString does not seem to work ??

  def to_s
    self.name
  end

  ###############
  ### PROCESS ###
  ###############
			
  def to_schema(xml) 
    root.to_schema(xml)
  end
	
  ## EXCEL
	
  def column_count
    root.column_count 
  end
 
  def row_count
    1000
  end

  # Note xml is expected to be Builder class 
	
  # Create an Excel XML Spreadsheet - worksheet contains XML Map
	
  def to_excel_xml(xml)
    root.to_excel_xml(xml)
  end
		
  def to_excel_map_schema( xml )
    root.to_excel_map_schema(xml) 
  end

  def to_excel_map_fields( xml )
    root.to_excel_map_fields(xml) 
  end
		
	
  # Create an Excel Spreadsheet 
		
  # http://builder.rubyforge.org/
  # http://rubyforge.org/projects/builder/
  #
  # Basically for Excel format is like this ..
  #<Row>
  #    <Cell><Data ss:Type="String">Leg_1_Params</Data></Cell>
  #    <Cell><Data ss:Type="String">Currency</Data></Cell>
  #    <Cell><Data ss:Type="String">/TRADE/Components/Leg1_Structured/Attributes/PayOffCcy</Data></Cell>
  #</Row>
  #
  def to_excel(xml) 
    # Header - Prod Name
    xml.Row 'ss:Height'=>'18' do
      xml.Cell('ss:StyleID'=> 's1') { xml.Data name, 'ss:Type' => 'String' }
    end
    xml.Row { xml.Cell }
    root.to_excel(xml)  
  end

	
  def down_migration( )
    if( table_created?(name.tableize) )
      msg = "drop_table :#{name.tableize}\n"
      components.each do |cm|
        cm.components.each do |c|
          msg << c.down_migration if c.respond_to? :down_migration
        end
      end
      msg
    end
  end
  
  def to_migration( )
    except =['id', 'created_at', 'updated_at']
    msg = "create_table :#{name.tableize}, :force => true  do |t|\n"
    
    attributes.each { |k,v| msg << "t.string  :#{k}\n" unless except.include?(k)}
  
    descendants.each do |c|
      c.components.each do |cp|
        msg << "t.integer  :#{cp.to_label.foreign_key}, :null => false\n" if cp.respond_to? :to_migration
      end
    end
    msg << "end\n"
   
    descendants.each do |cm|
      cm.components.each do |c|
        msg << c.to_migration if c.respond_to? :to_migration
      end
    end

    msg
  end
  
end
