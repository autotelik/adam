# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
# Usage : Should be called from database.rake tasks - which sorts out load paths, DB etc


module Adam
  class DataAlreadyLoaded < Exception; end

  module Loader

    Language.create(:name => 'JRuby', :version => '1.2')
    Language.create(:name => 'Java',  :version => '1.6.0_10')

    Language.create(:name => 'CalypsoAPI',  :version => '10')
    Language.create(:name => 'CalypsoML',  :version => '10')

    Language.create(:name => 'xsd',  :version => '10')
    Language.create(:name => 'XML')

    # XML TYPES
    ###########

    # TODO - check I have got complete list of XML types
    # ...for info ... http://en.wikipedia.org/wiki/XML_Schema_(W3C)
    # and add meta data as required

    # StructureBasicTypes
    # anySimpleType can be considered as the ·base type· of all ·primitive· datatypes.
    # anySimpleType is considered to have an unconstrained lexical space and a ·value space·
    # consisting of the union of the ·value space·s of all the ·primitive· datatypes and
    # the set of all lists of all members of the ·value space·s of all the ·primitive· datatypes.

    structs =['any', 'anyType', 'anySimpleType','element','complexContent','attributeGroup']

    structs.each {|s| BasicType.create(	:name => s, :name_space => 'xsd' ) }

    # Facets
    meta = "value\nfixed\nid\n"

    facets = ['length', 'minLength','maxLength', 'pattern', 'enumeration', 'whiteSpace',
      'minInclusive', 'minExclusive', 'maxInclusive', 'maxExclusive', 'totalDigits ','fractionDigits']

    facets.each {|f| BasicType.create(	:name => f, :name_space => 'xsd', :meta => meta ) }

    # DataBasicTypes

    data_types = ['anyURI',	'base64Binary','boolean', 'hexBinary','QName', 'string']

    data_types.each {|f| BasicType.create(	:name => f, :name_space => 'xsd' ) }

    BasicType.create(	:name => 'normalizedString',:base => 'string', :name_space => 'xsd')
    BasicType.create(	:name => 'token', 		:base => 'normalizedString', :name_space => 'xsd')

    BasicType.create(	:name => 'language',:base => 'token', :name_space => 'xsd')
    BasicType.create(	:name => 'NMTOKEN', :base => 'token', :name_space => 'xsd')
    BasicType.create(	:name => 'Name', 	:base => 'token', :name_space => 'xsd')

    BasicType.create(	:name => 'NMTOKENS', :base => 'NMTOKEN', :name_space => 'xsd')

    BasicType.create(	:name => 'NCName', 	:base => 'Name', :name_space => 'xsd')

    BasicType.create(	:name => 'ID', 	:base => 'NCName', :name_space => 'xsd')
    BasicType.create(	:name => 'IDREF', 	:base => 'NCName', :name_space => 'xsd')
    BasicType.create(	:name => 'IDREFS', 	:base => 'NCName', :name_space => 'xsd')


    BasicType.create(	:name => 'decimal', :name_space => 'xsd' )
    BasicType.create(	:name => 'integer', :base => 'decimal', :name_space => 'xsd' )

    BasicType.create(	:name => 'nonNegativeInteger',  :base => 'integer', :name_space => 'xsd' )
    BasicType.create(	:name => 'nonPositiveInteger',  :base => 'integer', :name_space => 'xsd' )
    BasicType.create(	:name => 'positiveInteger', :base => 'nonNegativeInteger', :name_space => 'xsd' )
    BasicType.create(	:name => 'negativeInteger', :base => 'nonPositiveInteger', :name_space => 'xsd' )

    BasicType.create(	:name => 'long',  		:base => 'integer', :name_space => 'xsd' )
    BasicType.create(	:name => 'int',  		:base => 'long', 		:name_space => 'xsd' )
    BasicType.create(	:name => 'short',  		:base => 'int', 		:name_space => 'xsd' )
    BasicType.create(	:name => 'byte',  		:base => 'short', 	:name_space => 'xsd' )

    BasicType.create(	:name => 'unsignedByte',  	:base => 'nonNegativeInteger', :name_space => 'xsd' )
    BasicType.create(	:name => 'unsignedInt',  	:base => 'nonNegativeInteger', :name_space => 'xsd' )
    BasicType.create(	:name => 'unsignedLong',  	:base => 'nonNegativeInteger', :name_space => 'xsd' )
    BasicType.create(	:name => 'unsignedShort',  	:base => 'nonNegativeInteger', :name_space => 'xsd' )

    BasicType.create(	:name => 'float', 		:name_space => 'xsd' )
    BasicType.create(	:name => 'double', 		:name_space => 'xsd' )

    BasicType.create(	:name => 'date', 		:name_space => 'xsd' )
    BasicType.create(	:name => 'dateTime', 	:name_space => 'xsd' )
    BasicType.create(	:name => 'duration', 	:name_space => 'xsd' )
    BasicType.create(	:name => 'time', 		:name_space => 'xsd' )

    BasicType.create(	:name => 'gDay', 		:name_space => 'xsd' )
    BasicType.create(	:name => 'gMonth', 		:name_space => 'xsd' )
    BasicType.create(	:name => 'gMonthDay', 	:name_space => 'xsd' )
    BasicType.create(	:name => 'gYear', 		:name_space => 'xsd' )
    BasicType.create(	:name => 'gYearMonth',	:name_space => 'xsd' )

    puts "#### DATA LOAD COMPLETE ####"
  end
end

    