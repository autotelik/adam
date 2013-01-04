# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
require 'xml_ability'
require 'schemable'
require 'awesome_nested_set'

class Composer < ActiveRecord::Base
  
  include Schemable

  # Note callbacks specified before associations to ensure entire calback Q is created/called
  
  before_create :ensure_type_on_create

  belongs_to    :asset

  # Only one Root Composer (Asset.root) with same name allowed per project. For ease of finding a Composer
  # in a project, join Composer directly to Project, rather then trying to go through Asset
  belongs_to    :project

  has_one       :composer_type
  # TODO - can we get to the klass directly rather than via composer_type.klass
  # has_one     :klass, :through => :composer_type, :dependent => :destroy

  
  # TODO has_one     :property, :as => :element, :dependent => :destroy

  has_many    :annotations, :as => :element, :dependent => :destroy

  has_many    :mappings, :class_name => 'ComposerMapping', :dependent => :destroy
  has_many    :system_key_fields, :through => :mappings
  

  # Composer is a self referential class/table, a parent may have many children
  # and we use ordered tree of children as processing e.g transformations
  # may require definitive order i.e some low level tags, rely on earlier tags
  # http://ordered-tree.rubyforge.org/

  #acts_as_ordered_tree :foreign_key => :parent_id,  :order => :position
  
  # Note we have multiple root nodes so needs a scope
  
  acts_as_nested_set :scope => :asset_id, :class => Composer  # required as we use single-table inheritance

  # Returns this record's immediate children of type e.g AttributeComposer

  # TODO - is it more efficient to simply filter children
  # which may be cached ? e.g. detect {|c| c.is_a? AttributeComposer }

  # TODO - written before scopes .. check out new active record methods to improve this code
  def children_of_type( klass )
    base_set_class.find(:all,
                        :conditions => ["#{scope_condition} AND #{parent_col_name} = #{self.id} AND type = ?", klass.to_s],
                        :order => left_col_name)
  end

  def children_not_of_type( klass )
    base_set_class.find(:all,
                        :conditions => ["#{scope_condition} AND #{parent_col_name} = #{self.id} AND type != ?", klass.to_s],
                        :order => left_col_name)
  end

  # ActiveRecord class - don't put extra init in initialize, use this method.

  def after_initialize
  end

  # The before create filter, if no project provided, we can assume it's same as the Assets

  def ensure_type_on_create
    if self.type.nil?
      self.type = self.class.name
    end
    if self.project.nil?
      self.project = self.asset.project unless self.asset.nil? || self.asset.project.nil?
    end
  end
  
  def self.find_by_xml_name( project, xml_name )
    raise ArgumentError, "Param 1 to find_by_xml_name must be of type Project" unless  project.is_a? Project
    
    n,t = XMLAbility::namespace_and_type( xml_name )
											
    return Composer.find_by_name_and_project_id(t, project.id) if( t )#and n != 'xsd' )
											
    nil						
  end	
		
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end

  def has_children?
    return (all_children.size > 0)
  end

  def leaf?
    return (children.size == 0)
  end

  # TODO - should this be a validation no ws allowed on create ?
  # Name to output for XML - No whitespace allowed
  def xml_name
    self.name.gsub(/\s/, "_")
  end

  # TODO - Required by Swing components, overloading toString does not seem to work ??

  def to_s
    self.name
  end

  # What : Clone an existing Composer and it's children 
  # Args : new_name - if provided create new child of self and clone found Composer to that child,
  #										else clone found Composer direct to self						
  def clone_and_add( existing_composer, new_name = nil)

   # puts "IN composer - CLONE #{existing_composer.name} TO #{self.name}:#{self.id}"
    return nil unless(existing_composer)

    raise ArgumentError, "Cannot clone diffrent type - expected Composer" unless existing_composer.is_a? Composer
  
    if( new_name )
      child = Composer.new(:name => new_name, :project => self.project, :asset => self.asset)
      child.move_to_child_of self
      child.copy( existing_composer )
      child.save
      return child
    else
      self.copy( existing_composer )
      return self
    end   
  end
					
  # Deep Copy the underlying structure (children) from another Composer
  # 
  def copy( from )   
    begin
      #puts "composer : About to call children on #{from.id}:#{from.name}"
      from.children.each do |c|
        #puts "Process Child #{c.id}:#{c.name}"
        child = c.class.new(:name => c.name, :project => self.project, :asset => self.asset)

        if child
          child.create_composer_type( :klass => c.composer_type.klass ) if c.composer_type
          child.move_to_child_of self
          child.copy( c )	# descend tree
        else
           raise ActiveRecordError, "Failed to create database object Composer for Asset #{asset.name}"
        end
      end

      self.save
    rescue => e
      puts e.inspect
      #e.backtrace.each {|b| puts b }
      puts "composer ERROR - failed to clone #{from.id} : #{from.name}"
      exit
    end
    
    # TODO - properties
    #        if(child.property)
    #          property = copy_leaf.property.clone 
    #          property.element = lf
    #          property.save
    #        end
  end

    
  #  # ############
  #  # OUTPUT VIEWS
  #  # ############
  
  # Collection of all child nodes contributing to output view
  # of a particular system (via AssetSchema)
  # e.g composer.excel_nodes, node.xml_nodes
  
  Schemable::schema_names.each do |sys|
    classevalstr=<<-EOF
      def #{sys}_nodes
          @#{sys}_nodes = all_children.select { |n| n.#{sys}? == true }
          @#{sys}_nodes
      end
    EOF
    class_eval classevalstr
  end 
  
  #  def to_schema(xml)
  #    puts "COMPOSER  #{self.name} children #{children.inspect}"
  #    if name and name.size > 0
  #      xml.tag!( name.gsub(/\s/, "_") ) do
  #        children.each { |child| child.to_schema(xml) }
  #      end
  #    else
  #      children.each { |child| child.to_schema(xml) }
  #    end
  #  end
  #
  #
  #  def to_xsd( xml )
  #
  #    n = label.gsub(/\s/, "_")
  #    t = n.upper_first_letter
  #
  #    xml.tag!( "xs:element", { "name" => n,  "type"  => t, "ptr_type" => "#{self.class.name}"} )
  #
  #    xml.tag!("xs:complexType", {"name" => t }) do
  #      xml.tag! "xs:sequence" do
  #        children.each { |child| child.to_xsd(xml) }
  #      end
  #    end
  #  end
  #
  #
  #  #TODO - when size  is 0, returning 1 still causes some issues elsewhere
  #
  def column_count
    res = excel_nodes()
    res.size == 0 ? 1 : res.size
  end
  #
  #
  #  def to_excel_xml(xml, indent = 0)
  #    xml.Row do
  #      xml.Cell('ss:StyleID'=> 's22') do
  #        xml.Data self.to_label.upcase, 'ss:Type' => 'String'
  #      end
  #    end
  #    xml.Row do 				# The XML Map Row Headings
  #      excel_nodes.each { |n|
  #        xml.Cell('ss:StyleID'=> 's23') do
  #          xml.Data n.to_label, 'ss:Type' => 'String'
  #          xml.NamedCell('ss:Name'=>"_FilterDatabase")
  #        end
  #      }
  #    end
  #  end
  #
  #
  #
  #
  #  def to_excel_map_fields( xml )
  #    i = 0
  #
  #    # We expect The object label, then Header at R2, data starts at R3
  #
  #    xml.tag!("x2:Map", {"x2:ID"=>"Root_Map", "x2:SchemaID"=>"Schema1", "x2:RootElement"=>"Root"} ) do
  #      xml.tag!("x2:Entry", { "x2:Type"=>"table", "x2:ID"=>"1", "x2:ShowTotals"=>"false"} ) do
  #        xml.tag!("x2:Range", "#{asset.name}!R3C1:R#{asset.row_count}C#{column_count}" )
  #        xml.tag!("x2:HeaderRange", "R2C1")
  #        xml.tag!("x:FilterOn", "True")
  #        xml.tag!("x2:XPath","/Root/Row")
  #
  #        excel_nodes.each  do |child|
  #          rc = (i == 0) ? 'RC' : "RC[#{i}]"
  #          xml.tag!('x2:Field', {'x2:ID' => child.to_label } ) do
  #            xml.tag!('x2:Range', rc)
  #            xml.tag!('x2:XPath', child.to_label)
  #            xml.tag!('x2:XSDType', 'string')
  #            xml.tag!('ss:Cell')
  #            xml.tag!('x2:Aggregate', 'None' )
  #          end
  #          i += 1
  #        end
  #      end
  #    end
  #
  #    #puts xml.target!
  #  end
  #
  #

  # Note xml is expected to be Builder class 
			 
  def down_migration( )
    msg = "drop_table :#{name.tableize}\n"  if( table_created?(name.tableize) )
  end
  
  def to_migration( )
    msg = "create_table :#{name.tableize}, :force => true  do |t|\n"
    
    tags.each {|t| msg << "t.string  :#{t.label}\n" }
    
    msg << "end\n"
    msg
  end
    
  # How to display sel & relationships in active scaffold GUI/XML
  
  def to_label 
    self.name
  end
 
  def to_children
    msg = ""
    children.each {|c| msg << "#{c.to_label};"}
    msg
  end
  
  def to_parent
    parent.to_label if parent
  end
  
end
