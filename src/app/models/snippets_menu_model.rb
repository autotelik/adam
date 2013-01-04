# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#
require 'snippet'

java_import javax.swing.AbstractAction

class SnippetAction < javax.swing.AbstractAction

  def initialize( snippet )
    super(snippet.name)
    putValue("Snippet", snippet)
  end

  def snippet
    getValue( "Snippet" )
  end

  def actionPerformed( event )
  end
end


class SnippetsMenuModel

  attr_accessor :items, :grouped_items
  
  # N.B - Called by controller to create variable (@__model) but also
  # Called every time controller calls view_state, which returns
  # a new instance of the model - so keep as light as possible
  def initialize
    @items = []
    @grouped_items ={}
  end
  
  def load_snippets()  
    @items = Snippet.find(:all, :order => :name).inject([]) { |a,s| a << SnippetAction.new(s); a }
    
    puts "load_snippets #{@items.class} #{@items.inspect}"
    @grouped_items = {}
    @items.each do |s|
      if @grouped_items[s.snippet.group]
        @grouped_items[s.snippet.group] << s
      else
        @grouped_items[s.snippet.group] = [s]
      end
    end
  end
  
end