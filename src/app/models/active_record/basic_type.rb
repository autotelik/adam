# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
# Details::   A Primitive type (not defined in terms of other datatypes )
#             and shared across projects. Not expected to contribute to schema structures,
#             but can affect way in which output data exported or displayed

class BasicType < ActiveRecord::Base

	validates_uniqueness_of :name,       :scope => :name_space
	validates_uniqueness_of :name_space, :scope => :name

  def self.find_base_from_xml( xml )
		
    if xml.elements['xsd:restriction']
      return xml.elements['xsd:restriction'].attributes['base']
					
    elsif xml.elements['xsd:list']
      return xml.elements['xsd:list'].attributes['itemType']
    else
      'xsd:string' 	
    end
  end

  # Normal find but for convience tries other possible combinations
  # i.e also handles cases where ns may be embedded in name,
  # e.g will succeed for ( 'xsd', 'string' ), ('xsd', 'xsd:string') & ('', 'xsd:string')
  #
  def self.multi_find_by_name( name, ns = nil, strict = false)
    return nil if name.nil?
    
    if ns
      result = find_by_name_space_and_name(ns, name)
      return result if result
    else
      result = find_by_name(name)
      return result if result
    end

    embed_ns, embed_name = name.split(':')
    return nil if( strict && (ns != embed_ns))
      
    return find_by_name_space_and_name(embed_ns, embed_name)
  end

  def self.namespace_type( type_str )
    return nil, nil if type_str.nil?
    return type_str.split(':')
  end
	
end
