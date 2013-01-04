# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
# Usage :
# =>          Add callbacks for actionEvent triggering actionPerformed, for example from a Menu,
#             associate each MenuItem with a callback.
#
#             The callbacks are keyed on actionEvent.getActionCommand (incoming events's getActionCommand)
#             which contains for example in Menus the MenutItem name.
#
#             Callbacks can be methods on the client class or blocks.
#
#             Example :
#
#             items = ["New Project", "New Asset", "New Node"]
#
#             listener = RubyActionListener.new( self )
#
#             listener.add_callback_method("New Project", :call_add_project_method )
#
#             listener.add_callback("New Asset") do
#                 # process new asset
#             end
#
#             listener.add_callback("New Node") do |event|
#                 # process node based on event argument
#             end
#
require 'ruby_event_listener'

class RubyActionListener < RubyEventListener
  java_import java.awt.event.ActionListener
  java_import java.awt.event.ActionEvent

  def initialize( call_back_parent )
    super(call_back_parent)
  end

  def actionPerformed(actionEvent)
    #puts "IN RubyActionListener : actionPerfomed"
    return if actionEvent.nil?

    callbacks = get_callbacks("#{actionEvent.getActionCommand}".to_sym)
    callbacks.each do |method|  
      if method.kind_of? Proc
        (0 == method.arity) ? method.call : method.call(actionEvent)
      else
        @parent.send(method, actionEvent)
      end
    end
  end
end