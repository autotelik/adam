# Copyright:: (c) Tom Statter for Autotelik Media Ltd 2011
# Author ::   Tom Statter
# Date ::     July 2011
# License::   Dual license : permission given to use this code under two licenses.
# => TBD one license (probably GPL) for free (no cost) programs
# => TBD one for commercial programs
#
require 'exceptions'
require 'excel_system'

require 'jruby_interactive_controller'
require 'popup_menu_controller'
require 'asset_tree_controller'
require 'schema_tab_controller'
require 'conversion_tab_controller'
require 'mapping_tab_controller'
require 'snippets_menu_controller'
require 'ruby_message_dialogs'


class AdamController < ApplicationController

  set_model 'AdamModel'
  set_view  'AdamView'
  set_close_action :exit
          
  # order of init is controller, view, model

  def load

    # TODO - add permissioning
    # user = UserController.instance
    # user.open

    puts "In AdamController : load"
    #
    # Now load projects + associated assets, force population of the AssetList
    model.load_projects

    #################################################
    # MANAGE ALL THE TABS ADDED TO THE MAIN WORK PANE
    #################################################

    # ** Note ** :name must match view's sub_view name i.e both must be :mapping_tab
    #
    @mapping_tab_controller = MappingTabController.instance
    @mapping_tab_controller.load
    add_nested_controller(:mapping_tab, @mapping_tab_controller)

    @conversion_tab_controller = ConversionTabController.instance
    @conversion_tab_controller.load
    add_nested_controller(:conversion_tab, @conversion_tab_controller)

    @schema_tab_controller = SchemaTabController.instance
    @schema_tab_controller.load
    add_nested_controller(:schema_tab, @schema_tab_controller)

    @asset_tree_controller = AssetTreeController.instance
    @asset_tree_controller.load( self )
    add_nested_controller(:asset_tree, @asset_tree_controller)

    @jirb_tab_controller = JRubyInteractiveController.instance
    @jirb_tab_controller.load(self)
    add_nested_controller(:jruby_interactive, @jirb_tab_controller)

    # N.B. Ensure new panels are added here
    # This forwards event to each added Pane to advise  they may have become selected/deselected

    define_handler(:workTabPane_state_changed) { |event| workTabPane_state_changed(event) }
    define_handler(:workTabPane_state_changed) { |event| @schema_tab_controller.workTabPane_state_changed( model ) }
    define_handler(:workTabPane_state_changed) { |event| @mapping_tab_controller.workTabPane_state_changed( model ) }
    define_handler(:workTabPane_state_changed) { |event| @conversion_tab_controller.workTabPane_state_changed( model ) }
    define_handler(:workTabPane_state_changed) { |event| @jirb_tab_controller.workTabPane_state_changed( model ) }


    # Define here so we get decent picture of the dependancy chain, the handlers appear to
    # be called in order of definition  - which can be important when forwarding on action to nested controllers 
    # 
    # TODO - Cannot currently get their own handlers to work in nested controllers
    #  e.g. AssetTreeController just will not pick up mouse events on the tree - perhaps they are somehow
    #  implicitly slurped up here but cannot see a way to remove implicit handlers
    #    ... anyway would be nice to find a better way than this
    #
    define_handler(:assetList_value_changed) { |event| assetList_value_changed(event) }
    define_handler(:assetList_value_changed) { |event| @asset_tree_controller.asset_selected( model ) }
    define_handler(:assetList_value_changed) { |event| @schema_tab_controller.asset_selected( model ) }
    define_handler(:assetList_value_changed) { |event| @mapping_tab_controller.asset_selected( model ) }

    define_handler(:assetTree_mouse_clicked) { |event| @asset_tree_controller.assetTree_mouse_clicked(event) }


    #########################
    # Build the Dynamic Menus
    #########################

    @snippets_menu_controller = SnippetsMenuController.instance

    # The list of controllers that want to know when a snippet is selected
    listeners = [@jirb_tab_controller]

    nest_menu('toolsMenu', @snippets_menu_controller, :snippets_menu, listeners)

    # TODO - Create a way for extensions/plugins to register themselves with menus
    # Calypso moved out to experimental to be re done as a plugin
    #@calypso_services_menu_controller = CalypsoServicesMenuController.instance

    # The list of controllers that want to know when Calypso services are selected

    #listeners = [@jirb_tab_controller]

    #nest_menu('servicesMenu', @calypso_services_menu_controller, :calypso_services_menu, listeners)

    puts "OUT AdamController : load"
  end

  ################
  # EVENT HANDLING
  ################

  def assetList_value_changed(event)
    puts "IN controller : assetList_value_changed"
    update_model(view_state.first, :selected_asset_index)
    model.select_filtered_asset( view_state.first.selected_asset_index )
  end

  def workTabPane_state_changed( event )
    # Transfer data from the view to our model via mappings defined in the view
    update_model(view_state.first, :working_tab_index, :working_tab_name)
  end

  add_listener :type => :list_selection, :components => [:projectList]

  def projectList_value_changed(event)
    puts "IN controller : projectList_value_changed #{view_state.inspect}"#selected_project_index}"
    i = view_state.first.selected_project_index
    unless(model.selected_project_index == i || i == -1 )
      model.select_project( :index => view_state.first.selected_project_index )
      signal(:update_asset_list)
    end
  end

  #### ASSET FILTER ####

  # The user types text into filter - updatre Asset list accordingly

 #TODO add_listener :type => :document, :components => {"assetFilter.document" => "asset_filter" }
  
  def asset_filter_changed_update(event) 
    update_model(view_state.first, :asset_filter_text)      # Update the filter text
  end

  # All possible text changes map to same handler (above) in model
  alias_method :asset_filter_insert_update, :asset_filter_changed_update
  alias_method :asset_filter_remove_update, :asset_filter_changed_update

  
  ##############
  # OUTPUT VIEWS 
  ##############

  def to_XML_button_action_performed

    unless(view_state.first.selected_asset_index > 0)
      transfer[:error_message] = "No Asset selected for export to XML"
      signal(:raise_simple_error)
    else
      model.select_filtered_asset( view_state.first.selected_asset_index )
      begin
        model.to_xml
        # Mapping not working ... update_view
        signal(:new_output_text)
      rescue => e
        # TODO - exception handling dialog - maybe catch higher up ? Need to find good exception handling scheme for GUI apps
      end
    end
  end
  
  def to_calypso_button_action_performed
    model.select_filtered_asset( view_state.first.selected_asset_index )
    model.to_calypso
    signal(:new_output_text)
  end
 
  def to_excel_button_action_performed
    model.select_filtered_asset( view_state.first.selected_asset_index )
    model.spawn_excel
  end
  
  
  ########
  # IMPORT
  ########
 
  def import_XML_item_action_performed()
    puts "IN AdamController - IMPORT XML"
    begin
      # Define which file suffixes we can handle
      transfer[:export_type] = 'xml'
      signal :get_import_path   # fire up file chooser, wait for user input
      #
      #model.export_to(transfer[:export_path], transfer[:export_type])
      parser = XmlSystem.new

      proj = model.current_project

      parser.from( proj, transfer[:path])

      reload_assets
      
    rescue UserCanceledError; end

    #RubyMessageDialog.show( "Not in this version" )
  end

  def import_XSD_item_action_performed()
    puts "IN AdamController - IMPORT XSD"
    # pop up file chooser
    begin
      # Define which file suffixes we can handle
      transfer[:export_type] = 'xsd'
      signal :get_import_path   # fire up file chooser, wait for user input
      #
      #model.export_to(transfer[:export_path], transfer[:export_type])
      parser = XmlSystem.new
		
      proj = model.current_project

      # path where include files to be processed,
      # search for includes and process first if true
      #
      options = {:include_path => transfer[:include_path],
        :follow_includes => transfer[:follow_includes]}

      parser.from( proj, transfer[:path], options)

      reload_assets
      
    rescue UserCanceledError; end
    puts "OUT AdamController : IMPORT XSD"
  end

  

  def load_trade_filter_action_performed(event)
    code =<<-EOF
    datetime = ComCalypsoTkCore::JDatetime.new(ComCalypsoTkCore::JDate.getNow, 23, 59, 0, java.util.TimeZone.getDefault())

    filter = 'ALL'

    tradeFilter = @ds.getRemoteReferenceData().getTradeFilter(filter)

    if(tradeFilter.nil?)
      throw 'Unable to get requested trade filter'
    end

    trades = @ds.getRemoteTrade().getTrades(tradeFilter, datetime)
    EOF

    @jirb_tab_controller.write_code(code, true)
  end

  def connect_menu_item_action_performed(event)
    puts "IN - AdamController : connect_menu_item_action_performed"
    puts "#{event.inspect()}"
    puts "#{event.class}"
    #if( event.getButton == java.awt.event.MouseEvent::BUTTON3)     # doesn't seem to work .. maybe need to register as isPopupTrigger())
    # transfer[:event] = event
    #controller = CalypsoConnectionController.create_instance
    #controller.show
  end

  def connect_menu_item_state_changed(event)
    puts "IN - AdamController : connect_menu_item_state_changed"
    puts "#{event.inspect()}"
    puts "#{event.class}"
    #controller = CalypsoConnectionController.create_instance
    #controller.show
  end

  def new_calypso_item_action_performed()
    puts "IN - AdamController : new_calypso_item"  
    puts "OUT - AdamController : new_calypso_item"
  end


  #######
  # INPUT
  #######
  
  def add_project_button_action_performed
    puts "In ADAM : add_project_button_action_performed current #{model.selected_project_index}"
    c = ProjectController.instance
    begin
      c.open(model)
      puts "In ADAM : add_project_button_action_performed update #{model.selected_project_index}"
      update_view
    rescue UserCanceledError; end
  end

  def add_asset_button_action_performed
    begin
      a = AssetController.instance
     
      puts "IN add_asset_button_action_performed : #{model.current_project.name} : #{model.current_project.assets.size}"
      a.open(model.current_project)
      update_view
    rescue Exception => e
      $stderr << "Error Opening New Asset Dialog\n#{e}\n#{e.message}"
      return
    end
    # TODO - just update single project rather than full asset list?
    reload_assets
  end
  
  def add_composer_button_action_performed
    begin
      a = ComposerController.instance

      puts "ADD Composer To #{model.current_project.name}"
      a.open(model.current_project, model.asset)
      puts "DONE OPEN"
    rescue Exception => e
      $stderr << "Error Opening New Composer Dialog\n#{e}\n#{e.message}"
      return
    end
    # TODO - just update single project
    model.current_project.reload

    update_view
  end


  private
  

  # Add a nested menu controller
  # Args : add_to_menu - the name of our menu component to which new menu should be attached
  #        menu - the menu controller instance to nest
  #
  # ** Note ** :id must match view's sub_view id e.g both must be :blah_menu
  #
  def nest_menu(add_to_menu, menu, id, listeners)
    menu.load(listeners)

    transfer[:add_to_menu] = add_to_menu

    add_nested_controller(id.to_sym, menu)
  end
  
  def reload_assets
    model.load_assets_and_filter
    puts "UPDATE VIEW - ASSETS #{ model.current_project.assets.size}"
    signal(:update_asset_list)
  end
  
end
