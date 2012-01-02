# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
# Usage :     Base class for EventListeners not supported directly by MonkeyBars such as
# =>          actionEvent triggering actionPerformed, or
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

class RubyEventListener

  def initialize( call_back_parent )
    @methods = {}
    @parent  = call_back_parent
  end

  # Associate method to call on the parent, with a Menu Item
  #   add_callback("New Project", :add_project_button_action_performed )
  #
  def add_callback(action_command, &block)
    @methods[action_command.to_sym] = block
  end

  # Associate a Proc/block style callback, with a Menu Item
  # => listener.add_callback_method("New Asset") do
  #      puts "You called this New Asset block"
  #    end
  #
  def add_callback_method(action_command, method)
    if method.kind_of? Proc
        @methods[action_command.to_sym] = method
    else
        @methods[action_command.to_sym] = method.to_sym
    end
  end

  def get_callbacks(method)
    callbacks = []
    begin
      callbacks << @methods[method] if(@methods.key? method)
    rescue NameError; end
    callbacks
  end
end
