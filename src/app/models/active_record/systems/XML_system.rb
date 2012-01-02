require 'system'

# THE XML SYSTEM CLASS
# 
require 'read_from_xsd'
require 'read_from_xml'

require 'hpricot'

# http://code.whytheluckystiff.net/hpricot/
  
class XmlSystem < System

  # ActiveRecord class - don't put extra init in initialize, use this method.

  def after_initialize
    @export_ns = nil
  end

  attr_reader :export_ns

  def export_ns=( ns )
    @export_ns = ns
    @export_ns += ':' if ns[ns.size - 1].chr != ':'
  end

  @@xml_klass = REXML::Document
   
  #
  # TODO - Hpricot.XML or REXML::Document 
  def self.new_doc( xml_file )
    @@xml_klass.new( File.new(xml_file) )
  end
  # Parse an XML or XSD file 
	
  def from( project, file, options = {} )
    
    x_file = file
    
    if( ! File.exists?(x_file) )
      raise "ERROR - file #{x_file} not found"  # TODO exception class ??
    end
    
    puts "Process file #{x_file}"
    
    xml = XmlSystem::new_doc( x_file ) #Hpricot.XML( File.new(x_file) )
   
    if(xml.root.name == "xsd:schema" || xml.root.name == 'schema') 	
      reader = ReadFromXSD.new
      reader.from_xsd( project, xml, options)
    else
      reader = ReadFromXML.new
      reader.from_xml( project, xml )
    end		
  end

  ########
  # OUTPUT
  ########

  # The recursive call used by spawn, export

  def add( xml, composer )
    if composer.xml?
      # Process any attribute  children first, so we can pass to tag!
      attributes = {}
      composer.children_of_type( AttributeComposer ).each { |a| attributes[a.name] = "" }
      
      xml.tag!( "#{@export_ns}:#{composer.name.gsub(/\s/, "_")}", attributes ) do
        composer.children.each do |child| add(xml, child)  end
      end
    else
      composer.children.each { |child| add(xml, child) }
    end
  end

  # The recursive call used by generate
  # NOTE - XML cannot enclose both a value and child nodes  ..<A>blah<b>blah</b></A> is not valid ?
  #
  def add_with_value( xml, composer, index )
    # Process any attribute  children first, so we can pass to tag!
    attributes = {}
    composer.children_of_type( AttributeComposer ).each do |att|
      attributes[att.name] = "#{@value_map[att.id][index]}" if( @value_map[att.id] )
    end

    if( @value_map[composer.id] && composer.leaf? )
      xml.tag!("#{@export_ns}#{composer.xml_name}", "#{@value_map[composer.id][index]}", attributes)
    else
      if(@value_map[composer.id])
        puts "WARNING - Creating tag #{composer.xml_name} WITHOUT value content"
        puts "Check mapping for #{composer.xml_name} - It's a parent node so content would cause badly formed XML"
      end

      xml.tag!( "#{@export_ns}#{composer.xml_name}", attributes ) do
        composer.children_not_of_type( AttributeComposer ).each do |child| add_with_value(xml, child, index) end
      end
    end
  end

  # Create an XML representation of an Asset
  #
  def spawn(asset, options = {})
    puts "spawn XML output"

    composer = asset.root

    # Create the XML schema for this Asset.
    xml = Builder::XmlMarkup.new( :indent => 1)
    xml.instruct!

    attributes = {}
    composer.children_of_type( AttributeComposer ).each { |a| attributes[a.name] = "" }

    xml.tag! "#{@export_ns}#{composer.name}", attributes do
      composer.children_not_of_type( AttributeComposer ).each { |n| add( xml, n) }
    end

    return xml
  end

  alias_method :export, :spawn

  # Create an XML data file representing supplied Asset
  # Expects data supplied for nodes to be passed in via asset.data_store.value_map
  #
  def generate(asset, filename = nil)

    xml = Builder::XmlMarkup.new( :indent => 1 )
    xml.instruct!

    composer = asset.root

    # TODO Improve this - refactor data_store so acts like enumerator and provides direct access
    # i.e asset.data_store.each do ...  and asset.data_store[composer.id]
    @value_map = asset.data_store.value_map

    puts "COMPOSER #{composer}"
    puts "DS #{asset.data_store.inspect}"
    puts "DS #{asset.data_store.value_map.inspect}"
    # For each data set (row), create and populate a new XML version of the Asset
    (0..(asset.data_store.data_size - 1)).each do |index|
      attributes = {}
      composer.children_of_type( AttributeComposer ).each do |att|
        attributes[att.name] = "#{@value_map[att.id][index]}" if( @value_map[att.id] )
      end

      xml.tag! "#{@export_ns}#{composer.name}", attributes do
        composer.children_not_of_type( AttributeComposer ).each { |n| puts "ADD To #{n}"; add_with_value( xml, n, index ) }
      end
    end     # End each mapping row

     puts "OPEN #{filename}"
    File.open( filename, 'w') do |f|
      f << xml.target!
    end unless filename.nil?

    return xml.target!
  end

  # Read XML file and populate Composer structure with values populated with Data
  #
  def populate( asset, filename, options = {} )

    asset.data_store = AssetDataStore.new( asset )

    if( ! File.exists?(filename) )
      raise "ERROR - file #{filename} not found"  # TODO exception class ??
    end

    puts "Process file #{filename}"

    xml = XmlSystem::new_doc( filename ) #Hpricot.XML( File.new(x_file) )

    puts "Opened data file #{filename}"

    # TODO refactor this mapping finder into suitable class/module such as schemable
    composer_xml_map = {}
    asset.composers.each do |comp|
      xpath = comp.mappings.detect { |m| m.system_key_field.field == "XPath" }
      puts "MAP #{comp.name} TO #{xpath.value}" if xpath
      composer_xml_map[comp] = (xpath.value) if xpath # Maps a Composer to an XPath
    end

    # Now iterate over all XML elements and
    # MAP : Composer => data from xpath
    # TODO come back to the logic here, first stab looking inefficient,
    # can we seek in the XML for mapping_xpath
    #
    xml.each_recursive do |node|
      composer_xml_map.each do |comp, mapping_xpath|
        puts "ADD TEXT #{node.xpath} => #{node.text}"
        # gotcha with rexml - reduce repeating structure definitions like Value[0] to Value
        xp = node.xpath.gsub(/\[\d+\]/, '')
        asset.data_store.add(comp, node.text) if(xp == mapping_xpath)
      end
    end
  end

end