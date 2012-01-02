# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
# Utilities for the model class Mapping

class MappingHelper

  # Recursively build the set of those Composers +  children that can
  # be used in an Excel mapping

  def self.mappable_nodes( system, composer, mappable_nodes = [] )
    case system
    when ExcelSystem then return mappable_excel_nodes( composer, mappable_nodes)
    when XmlSystem   then return mappable_xml_nodes( composer, mappable_nodes)
    else                  return default_mappable_nodes( composer, mappable_nodes)
    end
  end

  def self.default_mappable_nodes( composer, mappable_nodes = [], tag = nil )
    tag ||= String.new
    tag += "/#{composer.name}"
    eval %Q(
        def composer.to_s
            "#{tag}"
        end
      )
    mappable_nodes << composer

    composer.children.each do |node| default_mappable_nodes(node, mappable_nodes, tag ) end

    mappable_nodes
  end

  def self.mappable_xml_nodes( composer, mappable_nodes = [], tag = nil )
    tag ||= String.new
    case composer
    when SequenceComposer, ChoiceComposer, ListComposer, AnonymousComposer then nil # Do not add this node but process children
    when RestrictionComposer then return              # Do not add this node or any of it's children
    when Composer then
      tag += "/#{composer.name}"
      # Singleton method to over ride default to_s on *this* object only.
      # We can use this technique to alter the way objects are displayed in a Swing component
      # depending on type of Component or use-case.
      # i.e default to_s returns self.name only but for this mapping table we want an XPath
      eval %Q(
        def composer.to_s
            "#{tag}"
        end
      )

      mappable_nodes << composer
    end

    composer.children.each do |node| mappable_xml_nodes(node, mappable_nodes, tag ) end

    mappable_nodes
  end

  def self.mappable_excel_nodes( composer, mappable_nodes = [], tag = nil )
    tag ||= String.new

    case composer
    when SequenceComposer, ChoiceComposer, ListComposer, AnonymousComposer then nil # Do not add this node but process children
    when RestrictionComposer then return              # Do not add this node or any of it's children
    when Composer then                                # Base Class so must come last
      tag += "#{composer.name}:" #
      # Singleton method to over ride default to_s on *this* object only.
      # We can use this technique to alter the way objects are displayed in a Swing component
      # depending on type of Component or use-case.
      eval %Q(
        def composer.to_s
          "#{tag}"
        end
      )
      mappable_nodes << composer
    else return
    end

    composer.children.each do |node| mappable_excel_nodes(node, mappable_nodes, tag ) end

    mappable_nodes
  end

end