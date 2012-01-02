# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
class MappingTabController < ApplicationController
  set_model 'MappingTabModel'
  set_view  'MappingTabView'
  set_close_action :close

  include_class java.awt.event.ItemEvent

  ##################
  # FORWARDED EVENTS (from main AdamController)
  ##################
 
  # User has clicked on or off our Tab, sync our model with current view,
  # and create transfer for all other data required from other controller
  #
  def workTabPane_state_changed( main_model )
    update_model(view_state.model, :mapping_source)

    transfer[:working_tab_index] = main_model.working_tab_index   # Set details from Main controller
    transfer[:working_tab_name]  = main_model.working_tab_name
    transfer[:asset]             = main_model.asset               
    signal :workTabPane_state_changed
  end

  ##################
  # EVENT HANDLERS
  ##################
  
  # User has selected a different Asset, requires exact same processing as workTabPane_state_changed
  #
  def asset_selected( main_model )
    workTabPane_state_changed( main_model )
  end

  # Listener for mappingSourceComboBox_action_performed just doens't seem to work
  # so rely on item_state_changed and look for 'seleced' event
  #
  def mapping_source_combo_box_item_state_changed(event)
    if(event.getStateChange == ItemEvent::SELECTED )
      puts "IN MappingTabController : ITEM STATE #{event.getItem} : CHANGE STATE [#{event.getStateChange}]"
      update_model(view_state.model, :mapping_source)
      signal :mapping_source_changed
    end

  end

  def mapping_populate_button_action_performed
    signal(:populate_mapping)
  end

  def mapping_clear_button_action_performed
    signal(:clear_mapping)
  end

  def mapping_clear_all_button_action_performed
    signal(:clear_all)
  end

  def mapping_load_button_action_performed
    signal(:load_mapping)
  end

  def mapping_save_button_top_action_performed
    signal(:save_mapping)
  end

  def mapping_save_button_top_action_performed
    signal(:save_mapping)
  end

  alias_method :mapping_save_button_bottom_action_performed, :mapping_save_button_top_action_performed

end