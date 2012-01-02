# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Dec 2008
# License::   MIT ?
#
include_class java.util.Enumeration
include_class javax.swing.tree.TreeNode

class RubyAssetTreeNode <  javax.swing.tree.DefaultMutableTreeNode

  attr_accessor :object, :name
  
  def initialize(object, is_leaf )
    @name = object.respond_to?(:name) ? object.name : object.to_s
    super(@name, is_leaf)
    @object = object
  end
end


class RubyAssetTreeModel < javax.swing.tree.DefaultTreeModel
   
  def initialize(asset, asks_allows_children = true)
   
    begin
      @root = RubyAssetTreeNode.new(asset, true)

      super(@root, asks_allows_children)

      add_tree_nodes(@root, asset.root)
    rescue => e
      # A project can have no assets, so we expect a nil asset now and then
      puts "RubyAssetTreeModel - Failed to display Asset #{asset.inspect}" unless asset.nil?
      puts e
    end
  end

  def add_tree_nodes(parent_node, composer)
    return if( composer.nil? or composer.name.nil? or composer.name.empty? )
    allows_children = (composer.children.size > 0)
    child = RubyAssetTreeNode.new(composer, allows_children)
    composer.children.each do |c|
      add_tree_nodes( child, c)
    end
    parent_node.add(child)
  end

end   # END MODEL CLASS

module KSE
  include_class 'autotelik.swing.DnDJTree'
end

class RubyAssetTree < KSE::DnDJTree
  def initialize()
    super
  end

  def expand_all
    i = 0
    while i < getRowCount
      expandRow(i)
      i += 1
    end
  end
end