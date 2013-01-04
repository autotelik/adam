# Author::    Tom Statter & Andy Griffiths
# Copyright:: (c) Kubris 2008
# License::   MIT ?

require "mapping_schema"

class ConversionController < ApplicationController
  set_view  'ConversionView'
  set_model 'Conversion'

  java_import java.awt.event.ItemEvent

  set_close_action :close

  def load()
    puts "IN ConversionController::load"
  end

  def create()
    puts "In ConversionController - create"

    # our model is the AR class Conversion - make sure we start each time with a blank instance,
    # otherwise can end up updating an existing model
    @__model = @__model.class.new

    transfer[:maps] = MappingSchema.find(:all, :select => [:asset, :reference, :source],:include => [:asset], :order => "assets.name")
    signal :create
  end

  def mapSchema_combo_box_item_state_changed(event)
    if(event.getStateChange == ItemEvent::SELECTED )
      puts "IN ConversionController : mapSchema_combo_box item selected"
      signal :reference_selected
    end
  end

  def asset_combo_box_item_state_changed(event)
    if(event.getStateChange == ItemEvent::SELECTED )
      puts "IN ConversionController : asset_combo_box_item_state_changed : item selected"
      signal :asset_selected
    end
  end

  def asset_load_button_action_performed(event)
    puts "IN ConversionController REF LOAD"
    ref = RubyInputDialog.show( "Please choose an Asset", "Choose Mapping Asset" )

    # If a string was returned, carry on, else they hit cancel
    return unless(ref && ref.size > 0)

    puts "Asset #{ref}"
    
  end

 def delete(del_model)
    @__model = @__model.class.find(del_model.id)
    raise ActiveRecord::RecordInvalid, "No Conversion found with ID #{del_model.id}" unless @__model
    @__model.destroy
    update_view
    puts "OUT ConversionController : delete"
  end


  def edit(edit_model)
    puts "3 #{self.object_id}"
    @__model = @__model.class.find(edit_model.id)
    raise ActiveRecord::RecordInvalid, "No Conversion found with ID #{edit_model.id}" unless @__model
    update_view
    signal :edit
    puts "OUT ConversionController : edit"
  end

  def data_source_browse_button_action_performed
    begin
      signal :browse_for_data_source

      update_model(view_state.model, :data_source)
      
    rescue UserCanceledError; end
  end

  def save_button_action_performed

    puts "IN ConversionController : save_button_action_performed"

    update_model(view_state.model, :name, :data_source, :mapping_schema)
    #model.mapping_schema = view_state.model.mapping_schema
    model.output_system  = view_state.model.output_system

    if model.valid?
      model.save
      close
    else
      puts "INVALID Conversion - Could not save "
     # update_view
    end
  end
  
  def close_button_action_performed
    close
  end  
end
