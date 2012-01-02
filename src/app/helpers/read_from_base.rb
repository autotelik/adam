# THE READ FROm BASE CLASS
# 
require 'dynamic_migrations'
require 'blank_slate'
require 'LogUtils'

class ManageTypesOptions
  CLONE=1
  SHARE=2
end


class ReadFromBase < BlankSlate

  # Nested classes to hold current context details

  class MissingTypes
    @@missing_roots = {}
    @@missing_types = []
    
    attr_accessor :composer, :root, :type

    def initialize(type, composer)
      @root     = composer.root.name
      @composer = composer
      @type     = type

      # The roots contain the parents of all missing nodes, plus the count
      # of number missing per root, so we can tell when all missing nodes completed
      #
      @@missing_roots[@root] ? @@missing_roots[@root] += 1 :  @@missing_roots[@root] = 1
      @@missing_types << self
      puts "Missing #{@composer.id} => #{@type}"
    end

    # N.B The roots are Composers, parents of missing ADAM types. 
    # Their ADAM names will not contain any namespace info present in the XML
    # Missing types however contain XML names, which may/may not contain  namespace
    # So, to check for a root key best use this helper, which takes care of this for you
    #
    def self.missing_root_key?( typename )
      ns, type  = XMLAbility::namespace_and_type( typename )
      @@missing_roots[type]
    end

    def self.missing_roots
      @@missing_roots
    end

    def self.missing_types
      @@missing_types
    end

    def self.clear
      @@missing_roots = {}
      @@missing_types = []
    end
  end

  include DynamicMigrations
  include LogUtils

  attr_accessor :processed
  attr_accessor :asset, :project
 
  def initialize
      MissingTypes.clear
  end
  
  def method_missing(methodname, *args)       
    puts "WARNING - No implementation to parse [#{methodname}]"
  end


  # TODO - FIX THIS - have hardcoded xsd:  in lookups .. this can be xs: or not present at all 
  #  e.g how to do each("//xs:include") or each("//include")
  #
	
  def from_xsd( project, xml, options = {} )
    raise "Bad XML Schema data - no <schema> root node found" if(xml.root.name != "schema")

    @project = project
    @options = options	
    @processed ||= []
    MissingTypes.clear
  
    xml.root.attributes.prefixes.each { |ns| @namespace = ns unless ns == 'xsd' } 

    puts "Schema namespace #{@namespace}"

    # An xsd:include will contain Type information required to fully parse this file
    # so do them all first if requested. Look in current dir unless an include_path provided
    
    if( options[:follow_includes] )
      xml.root.elements.each("//xsd:include") do |e|
        f = e.attributes['schemaLocation']  
        x_file = options[:include_path] ? File.join( options[:include_path], f) : f 
        next if @processed.include?( x_file )
        puts "Parse xml include file #{x_file}"
        begin
          #x =
          from_xsd( project, REXML::Document.new(File.new(x_file)) , options )
        rescue => e
          puts "ERROR : #{e}"
          e.backtrace.each {|e| puts "#{e.inspect}" }
          puts "Failed to process include file #{x_file}"
        end
        @processed << x_file
      end
    end
    
    descend_tree( xml.root, XSDContext.new )

    # Try to fix any missing Types
    rescan
  end

  def descend_tree( base, context )        
    base.each_element do |child| 
      next if(child.name == 'include')
          
      self.__send__( child.name.intern, child, context )
    end 
  end

  # TODO - Bit nervous about this logic - is an infinite loop possible ?
  #
  # Idea is that roots contain the parents of all missing nodes, plus the count
  # of number missing per root.
  # This should enable us to process missing nodes in correct order. i.e where one missing type
  # itself includes another missing type, we want to process that second, lowest level one first,
  # to ensure it's complete, then use that newly completed type, to repair the higher level one
  # relying on it.

  def rescan

    roots = MissingTypes::missing_roots
    types = MissingTypes::missing_types

    types.each_with_index do |missing, i|

      # if missing type itself contains missing items, we need to fix that root first !
      next if(MissingTypes::missing_root_key?( missing.type ) )

      # Clone missing type nodes as children of the composer.
      # TODO - Right now, flag no update MissingTypes and delete it from types regardless
      # if found or not to stop infinite recursion when Type never defined !
      # this is because we only check in memory - the single read_from_xsd,
      # so need better persistent mechanism to flag missing types to enable rescan
      # after another file read
      #
      clone_or_share_existing( missing.type, missing.composer, false)
 
      types.delete_at(i)

      # Decrement the missing root count, and delete all together once no nodes left
      roots.delete_if { |k,v| roots[k] = roots[k] - 1 if(k == missing.root); roots[k] == 0 }
    end 
    
    # Try to ensure infinite loop not possible
    rescan unless(roots.nil? || roots.empty? || types.nil? || types.empty?)
  end

  def find_or_create_asset_and_root(name)
    if(@asset && (@asset = @project.assets.find(:first, :conditions => ["name = ?",  name])) )
      puts "Project #{@project.name} already contains Root Type [#{name}]"
      return @asset.root
      #raise "Bad XML Schema  - defines Type #{name} more than once"
    else
      puts "Project #{@project.name} add new asset [#{name}]"
      @asset = @project.assets.create( :name => name, :version => 1 )

      # 1-1 composer with asset - effectively the root node

      return ReadFromXSD::add_composer( @asset, name)
    end
  end

  def create_anonymous( context )
    child = AnonymousComposer.create(:asset => @asset)
    #child.save
    parent = context.is_a?(Composer) ? context : context.parent
    child.move_to_child_of parent if parent
    child
  end

  def clone_or_share_existing( type_name, parent, collect_missing = true)
    if(ctype = Composer::find_by_xml_name(@project, type_name))
      # If it's CLONE we clone complete structure, severing the association
      # otherwise, we simply return the type, which will be SHARED via composer_type association
      if(@options[:clone_or_share] == ManageTypesOptions::CLONE)
      
        #  Care needed we cannot clone Element whose Type is the same as one of it's direct parents
        #  otherwise will get infinite recursive copy
        #
        # i.e a cascading list
        #   <xsd:complexType name="HierarchyNode">
        #     <xsd:element name="name" type="xsd:string"/>
        #     <xsd:element name="childNode" type="HierarchyNode" minOccurs="0" maxOccurs="unbounded"/>
        # ChildNode cannot be cloned so we insert a RepeatingComposer. 
        # It's composer_type will indicate the repeating parent

        result = parent.ancestors.detect { |d| d.name == ctype.name }

        if(result)
          parent.type = 'RepeatingComposer'
          parent.save
          parent.create_composer_type( :klass => ctype )
        else
          puts "CLONE #{ctype.id} #{ctype.name} => #{parent.id} #{parent.name}"
          parent.clone_and_add(ctype)
        end
      end
    else
      puts "WARNING - Possible include error - type #{type_name} not found for #{parent.name} : #{parent.root.name}"
      MissingTypes.new(type_name, parent) if collect_missing
    end
    ctype
  end
end