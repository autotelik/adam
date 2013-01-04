# Copyright:: (c) Tom Statter for Autotelik Media Ltd 2011
# Author ::   Tom Statter
# Date ::     July 2011
# License::   Dual license : permission given to use this code under two licenses.
# => TBD one license (probably GPL) for free (no cost) programs
# => TBD one for commercial programs
#
java_import java.util.Vector
java_import javax.swing.JOptionPane

module KSE
  java_import 'autotelik.swing.FilteredJList'
  java_import 'autotelik.swing.AdamTreeNode'
end

java_import javax.swing.table.TableColumn;
java_import javax.swing.table.TableCellRenderer;

require 'system'
require 'ruby_asset_tree'
require 'ruby_import_xsd_dialog'
require 'ruby_mapping_table'

class AdamView < ApplicationView

  set_java_class 'AdamMDIApplication'

  # N.B Direction of conversion methods :using => [:from_model, :to_model]   
  map :view => "projectList.model", :model => :project_list, :using => [:build_list, nil]

  map :view => "outPutTextArea.text", :model => :output_text

  map :view => "workTabPane.getSelectedIndex", :model => :working_tab_index,  :using => [nil, :default]

  map :view => "workTabPane", :model => :working_tab_name,  :using => [nil, :get_tab_name]

  def load
    puts "IN AdamView : load"
  end

  # Populate the intial project and asset list
  # Important - Found the hard way - do the mapping afterwards otherwise we start triggering all sorts
  # of listeners/handlers on the assetList and projectList which causes chaos and error
  # listings which make no sense - maybe call to *disable_declared_handlers* sorts this issue out ?

  def on_first_update(model, transfer)

    puts "IN AdamView : on_first_update"
    super
    # No direct mapping for filtered AssetList handle it manually

    build_asset_list(model, transfer)

    # View assignment - selected_index doesn't work both ways selected_index so need bi-directional using

    AdamView::map :view => "projectList.getSelectedIndex", :model => :selected_project_index , :using => [nil, :default]

    # This style doesn't work
    # AdamView::map :view => "projectList.setSelectedIndex", :model => :selected_project_index , :using => [:default, nil]

    AdamView::raw_mapping :set_project_index, nil

    AdamView::map :view => "assetList.selected_index",     :model => :selected_asset_index ,  :using => [:default, nil]
    AdamView::map :view => "assetList.getSelectedIndex",   :model => :selected_asset_index ,  :using => [nil, :default]

   #TODO AdamView::map :view => "assetFilter.text", :model => :asset_filter_text

    #puts "OUT view : on_first_update"
  end

  # The raw mapping methods for update_view

  def set_project_index(model, transfer)
    projectList.setSelectedIndex( model.selected_project_index )
  end

  ###############
  ## SUB VIEWS ##
  ###############

  # ** Note ** :sub_view id must match controller's add_nested_controller id i.e :schema_tab, :mapping_tab etc

  # The TABS
  nest :sub_view => :schema_tab,          :using => [:add_tab_to_work, :remove_component]
  nest :sub_view => :mapping_tab,         :using => [:add_tab_to_work, :remove_component]
  nest :sub_view => :conversion_tab,      :using => [:add_tab_to_work, :remove_component]
  nest :sub_view => :jruby_interactive,   :using => [:add_tab_to_work, :remove_component]

  # The dynamic MENUS
  nest :sub_view => :snippets_menu,         :using => [:add_component_to_menu, :remove_component]
  nest :sub_view => :calypso_services_menu, :using => [:add_component_to_menu, :remove_component]

  # The component is supplied by nested view's @main_view_component/java class - i.e a MappingTabPanel

  def add_tab_to_work(sub_view, component, model, transfer)
    workTabPane.addTab(sub_view.class.tab_name, component)
  end

  def add_component_to_menu(sub_view, component, model, transfer)
    puts "IN AdamView : add_component_to_menu"
    raise ArgumentError unless transfer[:add_to_menu]
    instance_eval("#{transfer[:add_to_menu]}.add(component)")
  end

  def remove_component(view, component, model, transfer)
    puts "IN remove_component"
    #mappingTabPanel.remove component
  end

  nest :sub_view => :asset_tree, :using => [:define_asset_parent, :stub]

  # Pass the parent MDI component into sub view
  def define_asset_parent(view, component, model, transfer)
    view.load_component(@main_view_component, model.asset)
  end


  ########################################
  # ADAM VIEW MAPPING HELPERS AND SIGNALS
  ########################################

  # Get the Title of a tab

  def get_tab_name( tab )
    tab.getTitleAt( tab.getSelectedIndex )
  end
  
  
  ###############
  # PROJECT PANEL
  ###############

  define_signal :name => :update_asset_list, :handler => :update_asset_list

  # Refresh Asset navigation with this Project's Assets.
  # Fires selection value changed so that other panels can listen and update
  # relevant content accordingly
  # 
  def update_asset_list(model, transfer)
    puts "IN view :  project_selected"
    # Update Asset list to reflect change in selected project
    build_asset_list( model, transfer )

    i = model.selected_asset_index

    assetList.setSelectedIndex(i )

    assetList.fireSelectionValueChanged(i, i, false)
    #puts "OUT view :  project_selected"
  end

  ###############
  ## MAIN MENU ##
  ###############
  
  define_signal :name => :get_import_path, :handler   => :prompt_user_for_import_path

  # Create a file dialog for importing file into ADAM
  
  def prompt_user_for_import_path(model, transfer)
    transfer.merge!(RubyImportXSDDialog.get_import_details)
  end
   
  define_signal :name => :new_output_text,  :handler => :new_output_text
 
  def new_output_text(model, transfer) 
    outPutTextArea.text = model.output_text.to_s
    workTabPane.setSelectedComponent( outPutDesktop )
  end

  private
  
  def build_list(list)
    l_model = javax.swing.DefaultListModel.new()
    list.each {|t| l_model.addElement(t) }
    l_model
  end

  def build_asset_list(model, transfer)
     # TODO assetList.clear

     # model.filtered_assets.each {|t| assetList.add_item(t) }
  end
  
  def convert_to_vector(list)
    java.util.Vector.new(list)
  end

end