require 'rexml/document'

# TODO - This all needs tidying up and putting in different/correct modules

# Enable all our models with XML ability

 
module XMLAbility
 	
  def self.included(base)
    base.extend(ClassMethods)
		
		base.class_eval do				
			has_one :property, :as => :element, :dependent => :destroy
		end
  end
			
	
	# TODO - Move this to find_by_xml_xxxxx .. method_missing style ala ActiveRecord::Base
	
	def self.find_by_xml_name( xml_name )
								 
		n,t = XMLAbility::namespace_and_type( xml_name )
											
		return self.class.find_by_name(t)	if( t and n != 'xsd' )
											
		nil						
	end	
	
			
	def self.namespace_and_type( type_str )
				return nil, nil if type_str.nil?
				return nil,type_str unless type_str.include?(':')
				return type_str.split(':')
	end
		
	module ClassMethods		
			
	def find_base_from_xml( xml )
				
				if xml.elements['xsd:restriction']
					return xml.elements['xsd:restriction'].attributes['base']
							
				elsif xml.elements['xsd:list']
					return xml.elements['xsd:list'].attributes['itemType']
				else
					'xsd:string' 	
				end
	end
		
  # Store the current value associated with a node
  
  attr_accessor :current_value 
   
  # All repository elements with XMLAbility can be assigned additional
  # properties/validation etc via polymorphic properties table
	end  
end