# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
class ConversionView < ApplicationView
  set_java_class 'app.java.dialogs.ConversionDialog'

  module JavaFile
    include_class java::io::File
  end

  # N.B Direction of conversion methods :using => [:from_model (update_view), :to_model]
  #
  # The direct properties of model (Conversion)
  map :view => "nameTextField.text",                  :model => :name
  map :view => "dataSourceTextField.text",            :model => :data_source
  map :view => "outputSchemaComboBox.selected_item",  :model => :output_system,  :using => [nil, :default]
  map :view => "mapSchemaComboBox.selected_item",     :model => :mapping_schema, :using => [nil, :default]

  # The in-direct properties of model (Conversion)
  # map :view => "mapSchemaComboBox.selected_item", :model => 'mapping_schema.reference'

  map :view => 'assetComboBox.model',   :model => 'mapping_schema.asset', :using => [:to_combo_model, nil]

  # map :view => 'assetComboBox.selected_item', :model => 'mapping_schema.asset', :using => [nil, :find_mapping_schema]

  #  map :view => "outputSchemaComboBox.setSelectedItem",  :model => :output_system, :using => [:default, nil]
  # TODO - This doesn't work since it always calls the assignment operator i.e
  #   outputSchemaComboBox.setSelectedItem = model.output_system
  # we want :
  #   outputSchemaComboBox.setSelectedItem( model.output_system )
  #map :view => 'outputSchemaComboBox.model', :model => :output_system, :using => [:to_combo_model, nil]

  raw_mapping  :set_selected_output_system, nil    # to_view, from_view
  #raw_mapping  nil, :find_mapping_schema

  # Store the last visited dir for file chooser
  @@last_dir = "C:"

  # The update_view method

  def set_selected_output_system(model, transfer)
    puts "IN ConversionView : set_selected_output_system"
    outputSchemaComboBox.removeAllItems
    System.add_items(outputSchemaComboBox, {:order => 'type'})
    outputSchemaComboBox.setSelectedItem( model.output_system )
  end

#  def find_mapping_schema(model, transfer)
#    puts "IN ConversionView : find_mapping_schema"
#    reference = mapSchemaComboBox.selected_item
#
#    puts "Search mapping_schema : #{model.mapping_schema}"
#
#    model.mapping_schema =  mapSchemaComboBox.selected_item
#
#    puts "Found mapping_schema : #{model.mapping_schema}"
#  end

  define_signal :name => :edit,  :handler => :edit

  def edit(model, transfer)
    conversion = model
    puts "In ConversionView - edit #{conversion.inspect}"

    # These are for info only - cannot be edited in this dialog (MappingSchema)
    #assetComboBox.addItem( conversion.asset )
    assetComboBox.setSelectedItem( conversion.asset )
   
    mapSchemaComboBox.addItem(conversion.mapping_schema)
    mapSchemaComboBox.setSelectedItem( conversion.mapping_schema )

    sourceSchemaComboBox.addItem(conversion.mapping_schema.source.type)
    sourceSchemaComboBox.setSelectedItem( conversion.mapping_schema.source.type )
    
    [assetComboBox, mapSchemaComboBox, sourceSchemaComboBox].each {|c| c.setEditable( false ) }
  end

  define_signal :name => :create,  :handler => :create

  def create(model, transfer)
    puts "In ConversionView - create"
    map_schemas = transfer[:maps]

    if map_schemas.empty?
      RubyMessageDialog.show("Cannot create a Conversion - No Mappings defined yet")
      close
    else
      mapSchemaComboBox.removeAllItems
      map_schemas.each { |ms| mapSchemaComboBox.addItem(ms) }

      puts "SET SELCTED #{map_schemas.first.inspect}"

      assetComboBox.setEnabled false
      sourceSchemaComboBox.setEnabled false

      mapSchemaComboBox.setSelectedItem( map_schemas.first )

      outputSchemaComboBox.removeAllItems
      SystemHelper::add_items(outputSchemaComboBox)
    end
  end

  define_signal :name => :asset_selected,  :handler => :asset_selected

  def asset_selected(model, transfer)
    puts "IN  asset_selected : #{assetComboBox.isEnabled}"
    init = assetComboBox.getSelectedItem#transfer[:asset]

    if assetComboBox.isEnabled
      puts "POPULATE FORM FROM #{init.inspect}"
      #Asset.add_items(assetComboBox, {:args => {:order => 'name'} } )
      init.mapping_schemas.each {|i| mapSchemaComboBox.addItem(i.reference) }
      sourceSchemaComboBox.addItem(init.mapping_schemas.first.source)
    end
    puts "OUT asset_selected : POPULATE FORM FROM #{init.inspect}"
  end

  define_signal :name => :reference_selected,  :handler => :reference_selected

  def reference_selected(model, transfer)
    init = mapSchemaComboBox.getSelectedItem

    assetComboBox.removeAllItems
    sourceSchemaComboBox.removeAllItems

    if init
      assetComboBox.setEnabled false
      assetComboBox.addItem( init.asset )
  
      sourceSchemaComboBox.addItem(init.source)
      sourceSchemaComboBox.setEnabled false
    end
  end

  define_signal :name => :browse_for_data_source,  :handler => :browse_for_data_source

  def browse_for_data_source(model, transfer)

    include_class javax::swing::JFileChooser

    chooser = JFileChooser.new
    chooser.setCurrentDirectory( JavaFile::File.new( @@last_dir ) ) if @@last_dir
    chooser.setFileSelectionMode( JFileChooser::FILES_ONLY )

    result = chooser.showOpenDialog @main_view_component

    if(Java::javax::swing::JFileChooser::APPROVE_OPTION == result)
      transfer[:path] = chooser.selected_file.get_path

      dir, file = File.split(transfer[:path])
      @@last_dir = dir
      puts "SET DATA SOURCE : #{transfer[:path]}"
      dataSourceTextField.text = transfer[:path]
    else
      raise UserCanceledError.new("Nothing selected.")
    end
  end

end