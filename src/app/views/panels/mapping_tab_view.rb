# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
class MappingTabView < ApplicationView

  attr_accessor :main_view_component
  
  set_java_class 'app.java.panels.MappingTabPanel'

  # One way only (View -> Model)
  map :view => 'mappingSourceComboBox.selected_item', :model => :mapping_source, :using => [nil, :default]

  # raw_mapping :view => "mappingSourceComboBox", :using => [:populate_map_cbox, :stub]

  @@TAB_NAME = "Mapping Editor"
  def self.tab_name
    @@TAB_NAME
  end

  # The Map CBox contains the possible sources (systems) for the Mapping
  
  def load
    #puts "In MappingTabView - load"
    populate_map_cbox
  end

  # Hmmmm ??? never seems to get called for Nested Views
  def on_first_update(model, transfer)
    puts "In MappingTabView - on_first_update"
  end

  # Only bother with updating our view/model if we are current Tab.

  define_signal :name => :workTabPane_state_changed,  :handler => :workTabPane_state_changed
 
  def workTabPane_state_changed(model, transfer) #(asset)
   
    if(transfer[:working_tab_name] == @@TAB_NAME)
      puts "In MappingTabView - workTabPane_state_changed"

      if( transfer[:asset] != model.current_asset )
        # TODO Check if our init state has changed,  if YES, prompt user with WARNING to SAVE changes
        puts "ASSET CHANGED NEED TO SAVE ??"
      end

      model.current_asset = transfer[:asset]
      
      mappingScrollPane.setViewportView nil

      if(model.mapping_source)
        # Swap out the placeholder for our JRuby version
        # Note the use of @main_view_component here is vital, otherwise the assignment doesn't seem
        # to take across other methods - future calls to mappingTable will be old JXTable
        @main_view_component.mappingTable = RubyMappingTable.new(model.mapping_source, model.current_asset)
      end
      
      mappingScrollPane.setViewportView(mappingTable)
    end
  end

  ###########
  # MAPPINGS
  ###########

  define_signal :name => :mapping_source_changed,  :handler => :mapping_source_changed

  def mapping_source_changed(model, transfer)
    puts "IN MappingTabView : mapping_source_changed"
    mappingTable.system_change( model.mapping_source, model.current_asset )
  end

  define_signal :name => :populate_mapping,  :handler => :populate_mapping

  def populate_mapping(model, transfer)
    puts "IN MappingTabView : populate_mapping"
    mappingTable.populate
  end

  define_signal :name => :clear_all, :handler => :clear_all
  
  def clear_all(model, transfer)
    clear(0)
  end

  define_signal :name => :clear_mapping, :handler => :clear_mapping

  def clear_mapping(model, transfer)
    clear(1)
  end

  def clear(start_col = 0)
    map_model = mappingTable.model
    (0..map_model.getRowCount - 1).each do |r|
      (start_col..map_model.getColumnCount - 1).each { |c| map_model.set_value_at(nil, r, c) }
    end
  end

  define_signal :name => :load_mapping, :handler => :load_mapping

  def load_mapping(model, transfer)

    # N.B  find returns array of distinct ComposerMapping objects with only reference attribute filled in,
    # hence 'map' required to get just the string value of reference
    choices = MappingSchema.find(:all, :select => 'reference', :order => :reference).map(&:reference)

    if choices.empty?
      RubyMessageDialog.show("Sorry there are no saved mappings")
    else
      ref = choice_dialog( "Select Saved Mapping", choices, 0, "Load Mapping" )

      if ref
        parent = MappingSchema.find_by_reference( ref, :include => :composer_mappings)
       
        unless(parent.nil? || parent.composer_mappings.empty?)
           
          # TODO improve efficiency here, setSelected causes event trigger, which gens a blank table,
          #  so currently must come before populate, but this means we gen model twice, first a blank one
          #
          mappingSourceComboBox.setSelectedItem( parent.composer_mappings[0].system_key_field.system )
          mappingTable.populate_from_existing( parent )
        else
          RubyMessageDialog.show( "Sorry no mapping found with reference #{ref}")
        end
      end
    end
  end
  
  define_signal :name => :save_mapping,  :handler => :save_mapping

  def save_mapping(model, transfer)
    puts "IN MappingTabView : SAVE MAPPING"
    #do
      ref = RubyInputDialog.show( "Please enter a reference", "Mapping Reference" )

      # If a string was returned, carry on, else they hit cancel
      return unless(ref && ref.size > 0)

      map_schema = model.create(ref)

      unless map_schema.errors.empty?
       # TODO - create an ActiveRecord error dialog
        puts map_schema.errors.inspect
        RubyMessageDialog.show( "Sorry failed to save Mapping Schema" )
        return
      end
    #while(check here if s a valid & unique ref)
  
    system = model.mapping_source

    map_model = mappingTable.model
    col_ids   = map_model.getColumnIdentifiers

    # Create lookup map from column identifiers, to real SystemKeyField class
    fields = col_ids.inject({}) {|h,c| h[c] = system.key_fields.detect{|f| f.field == c}; h }

    (0..map_model.getRowCount - 1).each do |r|
      composer = map_model.getValueAt(r,0)
      next unless composer    # Not all rows are neccesarily filled in !
      #puts "Map to #{composer}"
      (1..map_model.getColumnCount - 1).each do |c|
        #puts "Map from #{fields[col_ids[c]]} -> #{map_model.getValueAt(r,c)}"
        composer.mappings.create(:mapping_schema => map_schema, :system_key_field => fields[col_ids[c]], :value =>  map_model.getValueAt(r,c))
        #puts composer.errors.each_full {|msg| p msg}
      end
    end
  end

  # The list of potential Mapping Sources
  
  def populate_map_cbox()
    puts "In MappingTabView - populate_map_cbox"
    SystemHelper::add_items(mappingSourceComboBox)
  end

end