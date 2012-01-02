require 'system'

class CalypsoSystem < System

  ########
  # OUTPUT
  ########

  # Generate Calypso schema example (data-less) of Composer and all children.
  # The recursive call used by spawn and export

  def add( xml, composer )
    if composer.calypso?
      # Process any attribute children first, so we can pass to tag!
      attributes = {}
      composer.children_of_type( AttributeComposer ).each { |a| attributes[a.name] = "" }
      
      xml.tag!( "calypso:#{composer.xml_name}", attributes ) do
        composer.children.each do |child| add(xml, child)  end
      end
    else
      composer.children.each { |child| add(xml, child) }
    end
  end

  # The recursive call used by generate
  # N.B - XML cannot enclose both a value and child nodes  ..<A>blah<b>blah</b></A> is not valid ?
  # 
  #  @value_map is of form {composer => [value, value, value] }
  #
  #  Possible that not all composers will have associated values
  #
  def add_with_value( xml, composer, index )
    # Process any attribute  children first, so we can pass to tag!
    attributes = {}
    composer.children_of_type( AttributeComposer ).each do |a|
      attributes[a.name] = "#{@value_map[a.id][index]}" if( @value_map[a.id] )
    end

    if( @value_map[composer.id] && composer.leaf? )
      xml.tag!("calypso:#{composer.xml_name}", "#{@value_map[composer.id][index]}", attributes)
    else
      if(@value_map[composer.id])
        puts "WARNING - Creating tag #{composer.xml_name} WITHOUT value content"
        puts "Check mapping for #{composer.xml_name} - It's a parent node so content would cause badly formed XML"
      end

      xml.tag!( "calypso:#{composer.xml_name}", attributes ) do
        composer.children_not_of_type( AttributeComposer ).each do |child| add_with_value(xml, child, index) end
      end
    end
  end
    
  # Aim is to be able to create the Calypso ML schema for an Asset
  # and also look up the API for this Asset and see what set methods we can call
  # on it, and create some kind of basic API program.
  #
  def spawn(asset, options = {})
    
    puts "spawn calypso output"
    
    format = options[:render] || :xml

    composer = asset.root
    
    if format == :xml
      # Create the Calypso ML schema for this Asset.
      xml = Builder::XmlMarkup.new( :indent => 1)
      xml.instruct!

      # Create and populate an example of calypso:calypsoObject
      attributes = object_attributes(composer)      # The default attributes, namespace etc

      composer.children_of_type( AttributeComposer ).each { |a| attributes[a.name] = "\"\"" }

      xml.calypso :calypsoDocument, {'xmlns:calypso'=>"http://www.calypso.com/xml" }  do
        # Now create the actual object and recursively all it's child nodes
        xml.calypso :calypsoObject, attributes do
          composer.children_not_of_type( AttributeComposer ).each { |n| add( xml, n) }
        end
      end
       
      return xml
    else
      # TODO - API
      java = String.new
      java << "#{asset.name.new} theAsset = new #{asset.name.new};"
      java << "theAsset.save"
      return java
    end
  end

  alias_method :export, :spawn
  
  # Create a CalypsoML data file representing supplied Asset
  # Expects data supplied for nodes to be passed in via asset.data_store.value_map
  # The
  #
  def generate(asset, filename = nil)

    xml = Builder::XmlMarkup.new( :indent => 1 )
    xml.instruct!

    composer = asset.root

    # TODO Improve this - refactor data_store so acts like enumerator and provides direct access
    # i.e asset.data_store.each do ...  and asset.data_store[composer.id]
    @value_map = asset.data_store.value_map

    # Can handle multiple objects but all need to be wrapped in a single 'calypsoDocument' (namespace calypso)
    xml.calypso :calypsoDocument, {'xmlns:calypso'=>"http://www.calypso.com/xml" }  do

      # For each data set, create and populate a new calypso:calypsoObject
      (0..(asset.data_store.data_size - 1)).each do |index|
        attributes = object_attributes(composer)

        composer.children_of_type( AttributeComposer ).each do |att|
          attributes[att.name] = "#{@value_map[att.id][index]}" if( @value_map[att.id] )
        end

        # Now create the actual 'calypsoObject' (namespace :calypso) and recursively all it's child nodes
        xml.calypso :calypsoObject, attributes do
          composer.children_not_of_type( AttributeComposer ).each { |n| add_with_value( xml, n, index ) }
        end
          
      end # End each mapping row
    end
  
    File.open( filename, 'w') do |f|
      f << xml.target!
    end unless filename.nil?

    return xml
  end

  private
 
  def object_attributes( composer )
    { 'xsi:type' => "calypso:#{composer.name}",
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance' }
  end
  
  def codifier( xml )
    xml.tag!('calypso:identification') do
      xml.tag!( 'calypso:versionedIdentifier', {'codifier'=>"convention"} )
    end
  end

  #
  #
  #  def to_xml( asset, data )
  #
  #    xml = Builder::XmlMarkup.new
  #    xml.instruct!
  #
  #    tags = data.shift
  #
  #    puts tags
  #
  #    composers, headers = [],[]
  #
  #    tags.collect  {|t| ns, n = t.split(':');  composers << ns; headers << n }
  #
  #    puts headers
  #
  #    xml.tag!('calypso:calypsoDocument', {'xmlns:calypso'=>"http://www.calypso.com/xml"}) do
  #      data.each do |row|
  #        xml.tag!('calypso:calypsoObject', {'xsi:type'=>"calypso:#{asset.name}", 'action'=>"SAVE", 'version'=>"10-0", 'xmlns:xsi'=>"http://www.w3.org/2001/XMLSchema-instance"}) do
  #
  #          codifier( xml )
  #
  #          row.each_with_index { |node, i| xml.tag!( headers[i], node) }
  #        end
  #      end
  #    end
  #
  #    xml
  #  end
	
end
