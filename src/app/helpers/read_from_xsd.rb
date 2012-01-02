# THE XSD PARSER
# 
# TODO - Benchmark REXML and hpricot  - probably move to hpicrot
# TODO - complete types ...for info ... http://en.wikipedia.org/wiki/XML_Schema_(W3C)
# TODO - investigate parsing @ http://www.service-architecture.com/xml/articles/specific_xml_vocabularies.html
# TODO - investigate parsing FpML ... http://www.fpml.org/

require 'rexml/document'
require 'hpricot'

class Hpricot::Doc
  alias :elements :search
end

require 'read_from_base'

class ReadFromXSD < ReadFromBase

  class XSDContext
    attr_accessor :parent

    def initialize( parent = nil )
      @parent = parent
    end
  end
  
  def initialize
    @context = XSDContext.new
    MissingTypes.clear
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

  ##############
  ## XSD ITEMS
  ##############

  def annotation( elem, context = XSDContext.new )
    #puts "ANNOTATION #{elem}"
    if(context.parent)
      context.parent.annotations.create
    end
    descend_tree(elem, context)
  end

  # <xsd:attribute name="codifier" type="xsd:string" use="required"/>

  def attribute( elem, context = XSDContext.new )
    composer = context.parent

    if(composer.nil? )
      # TODO - is this possible - check XSD standards
      puts "#### TODO - attribute WITH NO CONTEXT : #{elem.inspect}"
    else
      parent = ReadFromXSD::add_composer( composer.asset, elem.attributes['name'], composer, :type => AttributeComposer)

      unless(ctype = BasicType.multi_find_by_name( elem.attributes['type'], 'xsd' ) )
        ctype = Composer.find_by_xml_name( @project, elem.attributes['type'] )
        ctype = BasicType.multi_find_by_name( 'attribute', 'xsd' ) unless ctype
      end

      parent.create_composer_type( :klass => ctype ) if ctype
    end

    descend_tree( elem, XSDContext.new(parent))
  end
 
  def attributeGroup( elem, context = XSDContext.new )
    #puts "ATTRIBUTEGROUP #{elem}"
    composer = context.parent

    # Can either define a new attribute grouping or can be a reference to a grouping within
    # another high level type
    if(composer.nil?)
      # New grouping 1-1 composer with asset - effectively the root node
      parent = find_or_create_asset_and_root( elem.attributes['name'] )
    else
      parent = create_anonymous(context)

      if(elem.attributes['ref'].nil?)
        # TODO - can this happen, i.e is it valid XSD ???
        puts "TODO - Anonymous Attribute Group referenced by a parent - #{composer.name}"
      else
        ctype = clone_or_share_existing(elem.attributes['ref'], parent )
      end
    end

    ctype = BasicType.multi_find_by_name( 'attributeGroup', 'xsd' ) unless ctype
    parent.create_composer_type( :klass => ctype ) if ctype

    next_context = XSDContext.new(parent)
    descend_tree( elem, next_context )
  end

  def complexContent( elem, context = XSDContext.new )
    #puts "COMPLEX CONTENT"
    parent = create_anonymous( context )

    ctype = BasicType.multi_find_by_name( 'complexContent', 'xsd' )
    parent.create_composer_type( :klass => ctype ) if ctype

    @context.parent = parent

    descend_tree( elem, @context )
  end
  

  def complexContent( elem, context = XSDContext.new )
    #puts "COMPLEX CONTENT"
    parent = create_anonymous( context )

    ctype = BasicType.multi_find_by_name( 'complexContent', 'xsd' )
    parent.create_composer_type( :klass => ctype ) if ctype

    @context.parent = parent

    descend_tree( elem, @context )
  end

  # Process  xsd:complexType name"xyz"
  # An Asset. Can contain, a grouping of other Assets or nodes

  def complexType( elem, context = XSDContext.new )

    composer = context.parent

    #puts "START COMPLEX TYPE #{elem.attributes['name']} PARENT [#{composer.inspect}]"

    if(composer.nil?)
      # 1-1 composer with asset - effectively the root node
      parent = find_or_create_asset_and_root( elem.attributes['name'] )
    else
      if(elem.attributes['name'].nil?)
        # TODO - what kind of structure is this really ?
        puts "Anonymous ComplexType being added to #{composer.name}"
        parent = create_anonymous(context)
      else
        parent = ReadFromXSD::add_composer( composer.asset, elem.attributes['name'], composer)
      end
    end
   
    @context.parent = parent
    
    descend_tree(elem, @context)
  end

  def documentation( elem, context = XSDContext.new )
    
    if( context.parent )
      composer = context.parent
      if(composer.annotations.size > 0)
        # N.B assignment silently fails to update DB i.e this fails - annotations.last.documentation = "BLAH"
        composer.annotations.last.update_attribute(:documentation, elem.text.strip)
        
        unless composer.annotations.last.save
          context.parent.annotations.last.errors.each {|e| puts e }
          raise "Failed to create Annotation for #{context.parent.name}"
        end
      else
        composer.annotations.create( :documentation => elem.text.strip )
      end
    end
    descend_tree(elem, context)
  end

  def element( elem, context = XSDContext.new )
    puts "IN element #{elem}"
    parent = ReadFromXSD::add_composer( @asset, elem.attributes['name'], context.parent)

    if(elem.attributes['type'])

      # If type is not basic (xsd:blah) try to find Composer in this project of that type (blah)
      unless(ctype = BasicType.multi_find_by_name( elem.attributes['type'], 'xsd') )
        clone_or_share_existing(elem.attributes['type'], parent )
      end
    else
      ctype = BasicType.multi_find_by_name('element', 'xsd')
    end

    parent.create_composer_type( :klass => ctype ) unless( parent.composer_type || ctype.nil?)

    descend_tree( elem, XSDContext.new(parent) )
  end


  def enumeration( elem, context = XSDContext.new )
    composer = context.parent
    if composer.nil?
      # TODO - what do we do with an enum with no parent
      puts "#### TODO - An enum with no parent"
    else
      # enum vales should have same parent so don't change context
      enum  = ReadFromXSD::add_composer( composer.asset, elem.attributes['value'], composer)
      ctype = BasicType.multi_find_by_name( 'enumeration', 'xsd' )
      
      enum.create_composer_type( :klass => ctype ) if ctype
    end

    descend_tree( elem, context )
  end

  def extension( elem, context = XSDContext.new)
    raise "Cannot process 'extension': #{elem} - need a parent to extend" if context.parent.nil?
    # Try and find the 'base' Type within project

    existing = Composer::find_by_xml_name(@project, elem.attributes['base'])

    if existing
      context.parent.clone_and_add(existing)
    else
      # TODO - Create a list of missing BASE types - when found come back and fix
      # this composer
      puts "WARNING - Missing Base type #{elem.attributes['base']} - Nodes will be incomplete"
    end

    descend_tree( elem, context )
  end


  # TODO - Create methods for all XSD schema items as defined by
  # Simple Types
  
  def simpleType( elem, context = XSDContext.new )
    composer = context.parent

    #puts "IN simpleType - #{composer.inspect}"
    if(composer.nil? )
      # SimpleType to store as high level Type

      if(elem.attributes['name'])
        parent = find_or_create_asset_and_root( elem.attributes['name'] )
      elsif
        # TODO - what should we do here ?
        puts "#### TODO - SIMPLE TYPE WITH NO NAME : #{elem.inspect}"
      end
    else
      if( elem.attributes['name'] )
        parent = ReadFromXSD::add_composer( composer.asset, elem.attributes['name'], composer)
      else
        parent = create_anonymous(composer)
      end
    end

    ctype = BasicType.multi_find_by_name( 'simpleType', 'xsd' ) unless ctype

    parent.create_composer_type( :klass => ctype ) if ctype

    next_context = XSDContext.new(parent)

    descend_tree( elem, next_context )
  end
    	
  # xsd:list itemType="xyz"  ... e.g <xsd:list itemType="xsd:string"/>

  def list( elem, context = XSDContext.new )

    parent = nil
    
    if( context.parent )
      # We already have Type for the List in system - so create new Composer, adding to parent

      parent = ReadFromXSD::add_composer( @asset, elem.attributes['name'], context.parent, :type => ListComposer)

      unless( ctype = BasicType.multi_find_by_name(elem.attributes['itemType'], 'xsd') )
        ctype = Composer.find_by_xml_name( @project, elem.attributes['itemType'] )
      end

      parent.create_composer_type( :klass => ctype ) if ctype

    else
      #TODO - create exception log which can be re processed at end
      # so that if Type not found now, but defined later in file we can sort out issue
      # @missing[]
      puts "WARNING PROCESSING list : TYPE #{elem.attributes['itemType']} NOT FOUND IN SYSTEM"
    end

    @context.parent = parent
    descend_tree( elem, @context )

  end

  
  # Group of nodes in fixed order
    
  def sequence( elem, context = XSDContext.new )
    #log(:info, "IN sequence")
    
    parent = SequenceComposer.create(:asset => @asset)
    # TODO add composer_type
    if( parent )
      parent.move_to_child_of(context.parent) if context.parent

      next_context = XSDContext.new(parent)
    else
      puts parent.errors.inspect
      raise "DB SAVE ERRORS"
    end

    descend_tree( elem, next_context )

  end
  
  # Group of nodes - one of which may be present in parent composer
  
  # The choice element provides an XML representation for describing a selection from a set of element types.
  # An XML instance contains elements that correspond to a selection from the set of element
  # types defined by the choice element in an XML Schema Document.
  # The minOccurs and maxOccurs attributes may permit the XML instance to select several
  # (e.g. between two and four) occurrences of element types from the set.
  
  def choice( elem, context = XSDContext.new )
    #puts "CHOICE"
    parent = ChoiceComposer.create(:name => elem.attributes['id'], :asset => @asset)
    if(parent)
      parent.move_to_child_of context.parent if context.parent

      next_context = XSDContext.new(parent)
    else
      puts parent.errors.inspect
      raise "DB SAVE ERRORS"
    end
    descend_tree( elem, next_context )   # Add the choices
  end

  def pattern( elem, context = XSDContext.new )
    # TODO  - These facets should become property of context rather than composer in it's own right ??

    composer = context.parent
    if( composer )
      parent = ReadFromXSD::add_composer( composer.asset, elem.attributes['value'], composer, :type => PatternComposer)

      ctype = BasicType.multi_find_by_name( 'pattern', 'xsd' )
      parent.create_composer_type( :klass => ctype ) if ctype
      next_context = XSDContext.new( parent )
    else
      # TODO - is this possible - check XSD standards
      next_context = context
    end

    descend_tree( elem, next_context )
  end

  def restriction( elem, context = XSDContext.new )
    composer = context.parent

    if(composer.nil? )
      # TODO - is this possible - check XSD standards
      puts "#### TODO - RESTRICITON  WITH NO CONTEXT : #{elem.inspect}"
      parent = nil
    else
      parent = ReadFromXSD::add_composer( composer.asset, elem.attributes['name'], context.parent, :type => RestrictionComposer)

      if(elem.attributes['base'])
        ctype = BasicType.multi_find_by_name( elem.attributes['base'], 'xsd' )
        parent.create_composer_type( :klass => ctype ) if ctype
      end
    end

    next_context = XSDContext.new(parent)

    descend_tree( elem, next_context )
  end
  
  def whiteSpace( elem, context = XSDContext.new )
    # TODO  - This should become a property of context rather than composer in it's own right ??
    composer = context.parent

    if(composer.nil? )
      # TODO - is this possible - check XSD standards
      puts "#### TODO - whitespace WITH NO CONTEXT : #{elem.inspect}"
    else
      parent = ReadFromXSD::add_composer( composer.asset, elem.attributes['value'], composer)

      ctype = BasicType.multi_find_by_name( 'whiteSpace', 'xsd' )
      parent.create_composer_type( :klass => ctype ) if ctype
    end
    descend_tree( elem, context )
  end
end