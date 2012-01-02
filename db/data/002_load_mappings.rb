# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
# Usage : Should be called from database.rake tasks - which sorts out load paths, DB etc


module Adam
  class DataAlreadyLoaded < Exception; end

  module Loader
    
    ##############################################
    # RUBY TYPES - Example usage, validations of user input
    ##############################################
    puts "Creating BasicTypes for Ruby"

    BasicType.create(	:name => 'Object', :name_space => 'ruby')
    BasicType.create(	:name => 'Module', :name_space => 'ruby')
    BasicType.create(	:name => 'Class',  :name_space => 'ruby')
    strtype = BasicType.create(	:name => 'String', :name_space => 'ruby')
    fixtype = BasicType.create(	:name => 'FixNum', :name_space => 'ruby')
    BasicType.create(	:name => 'TrueClass', :name_space => 'ruby')
    BasicType.create(	:name => 'FalseClass', :name_space => 'ruby')

    ##############################################
    # Key fields on Systems for mapping/conversions
    ##############################################

    puts "Creating default Systems"

    [BbgSystem, XmlSystem, CsvSystem, ExcelSystem, CalypsoSystem, CalypsoApiSystem].each do |x|
      begin
        x.create!
      rescue ActiveRecord::RecordInvalid => invalid
        puts invalid.record.errors
      end
    end

    ex  = System.find_by_type( ExcelSystem.to_s )
    cap = System.find_by_type( CalypsoSystem.to_s )
    xml = System.find_by_type( XmlSystem.to_s )
    csv = System.find_by_type( CsvSystem.to_s )

    puts "Creating System's default Key Fields"

    ex.key_fields.create( :field => 'Worksheet', :basic_type => fixtype, :pop_default => '1' )
    ex.key_fields.create( :field => 'Column', :basic_type => fixtype, :pop_default => '1', :pop_auto_increment => true )

    xml.key_fields.create( :field => 'XPath', :basic_type => strtype )
    csv.key_fields.create( :field => 'Column', :basic_type => fixtype, :pop_default => '1', :pop_auto_increment => true  )

    capi = System.find_by_type( CalypsoApiSystem.to_s )
    capi.key_fields.create( :field => 'Jar File', :basic_type => strtype  )
    capi.key_fields.create( :field => 'Class', :basic_type => strtype  )
    capi.key_fields.create( :field => 'Method', :basic_type => strtype  )

    Project.create( :name => "testbed", :identifier => "tsb", :description => "Play area")
#    puts "Creating Mapping Schemas"
#
#    ms = MappingSchema.create(:asset_id=> 90, :reference=> 'acclimit', :source => ex)
#
#    puts "Creating Composer Mappings"
#
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1911, :value=> 1, :system_key_field => ex.key_fields[0]
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1910, :value=> 3, :system_key_field_id => 2
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1908, :value=> 1, :system_key_field_id => 1
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1906, :value=> 0, :system_key_field_id => 2
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1911, :value=> 4, :system_key_field_id => 2
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1910, :value=> 1, :system_key_field_id => 1
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1909, :value=> 2, :system_key_field_id => 2
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1906, :value=> 1, :system_key_field_id => 1
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1909, :value=> 1, :system_key_field_id => 1
#    ComposerMapping.create :mapping_schema => ms, :composer_id=> 1908, :value=> 1, :system_key_field_id => 2
#
#    puts "Creating Conversions"
#
#    Conversion.create( :mapping_schema => ms,
#      :data_source => "C:\\SoftwareDev\\JRuby\\ADAM\\test\\fixtures\\test_excel_data.xls", :output_system => cap)
#
#    Conversion.create( :mapping_schema => ms,
#      :data_source => "C:\\SoftwareDev\\JRuby\\ADAM\\test\\fixtures\\test_excel_data.xls", :output_system => xml)

    puts "#### DATA LOAD COMPLETE ####"
  end
end    