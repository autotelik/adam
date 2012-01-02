# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
# Manage the Asset Tree (assetTree) view TAB on the work panel
#

class AssetTreeView < ApplicationView
  include_class java.awt.event.MouseAdapter


  def create_main_view_component
   @main_view_component = RubyAssetTree.new
  end

  # We are a nested view, this is called from main View so we can get handle
  # on the main MDI app component which 'owns' all these sub components in our case assetTree
  #
  def load_component( mdi, asset )
    puts "IN AssetTreeView : load_component"
    @main_frame = mdi

    create_main_view_component

    # In nested view like this these 2 calls rely on the attributes of mdi being public
    #@main_frame.setAssetTree( RubyAssetTree.new )
    @main_frame.setAssetTree( @main_view_component )

    @main_frame.assetTreeScrollPane.setViewportView(@main_frame.assetTree)
    
    #@main_view_component = @main_frame.assetTree
    @main_view_component.model = RubyAssetTreeModel.new(asset, true)

    @main_view_component.expand_all
  end

  # User clicks on Asset in the Navigator List

  define_signal :name => :update_asset_tree,   :handler => :update_asset_tree

  # We don't have a model - all data passed via transfer

  def update_asset_tree(model, transfer)
    return unless transfer[:asset]

    asset = transfer[:asset]

    @main_view_component.model = RubyAssetTreeModel.new(asset, true)

    @main_view_component.expand_all
  end


  # Return the location of a mouse click in asset tree

  define_signal :name => :assetTreeMousePath,   :handler => :asset_tree_mouse_path

  def asset_tree_mouse_path(model, transfer)
    e = transfer[:event]

    sel = @main_view_component.getRowForLocation(e.getX(), e.getY())

    if(sel != -1)
      return @main_view_component.getPathForLocation(e.getX, e.getY)
    end
    nil
  end


end