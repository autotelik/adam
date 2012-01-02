# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
require 'exceptions'
require 'popup_menu_controller'
require 'ruby_message_dialogs'

class AssetTreeController < ApplicationController

  set_view  'AssetTreeView'
  set_close_action :close

  def load( controller )
    puts "IN AssetTreeController load"
    @parent = controller
  end
  ################
  # EVENT HANDLING
  ################

  # Note we don't have a model of our own & not sure it's good idea to assign model to our @__model
  # so communicate parent model data via our transfer.
  
  def asset_selected( model )
    puts "IN AssetTreeController : asset_selected"
    transfer[:asset] = model.asset
    signal :update_asset_tree
  end
  
  # User clicks the Tree displaying an Asset's construction
  # if RH button bring up context menu
  #
  def assetTree_mouse_clicked(event)
    puts "IN assetTreeMouseClicked : POPUP #{event.isPopupTrigger()}"
    puts "MOUSE #{event.class} : #{event.getClickCount} : BUTTON #{event.getButton}"
    if( event.getButton == java.awt.event.MouseEvent::BUTTON3)     # doesn't seem to work .. maybe need to register as isPopupTrigger())
      transfer[:event] = event

      items = ["New Project", :addSeparator, "Add Asset", "Add Node", :addSeparator, "Rename"]

      listener = PopupActionListener.new( self )

      listener.add_callback_method("New Project", :add_project_button_action_performed )

      listener.add_callback("Add Node") do
        path = signal(:assetTreeMousePath)
        return unless path

        add_to_tree_node = path.getLastPathComponent  # path.getPath.each do |element|

        c = Composer.find( add_to_tree_node.object.id )
        puts "ADD COMPOSER TO #{add_to_tree_node.object.id} : #{c.inspect}"
      end

      ## CONTEXT DEPENDENT AND OPTIONAL ITEMS ##

      path = signal(:assetTreeMousePath)

      if path
        obj = path.getLastPathComponent.object # path.getPath.each do |element|

        items << "Type Info" if(obj && obj.is_a?(Composer))
        items << "Documentation" if(obj && obj.respond_to?(:annotations) && obj.annotations.last)
     
        listener.add_callback("Documentation") do
          path = signal(:assetTreeMousePath)
          return unless path

          info = path.getLastPathComponent.object  # path.getPath.each do |element|

          RubyMessageDialog.show("#{info.annotations.last.documentation}") if info and info.annotations.last

        end

        listener.add_callback("Type Info") do
          path = signal(:assetTreeMousePath)
          return unless path

          c = path.getLastPathComponent.object  # path.getPath.each do |element|

          RubyMessageDialog.show("Type Info\n#{c.class} : #{c.composer_type.klass.name}") if c and c.composer_type
        end
      end
 
      pmenu = PopupMenuController.create_instance

      pmenu.open(event, items, listener )
    end
  end

  def add_project_button_action_performed( event )
    @parent.add_project_button_action_performed
  end

end