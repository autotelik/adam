# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Feb 2009
# License::   MIT ?
#
# Usage :
# =>          Add callbacks for PropertyChangeEvents triggering propertyChange
#
#             The callbacks are keyed on propertyChangeEvent.getPropertyName()
#
#             Callbacks can be methods on the call_back_parent, or blocks.
#
#             Example :
#           
#
require 'ruby_event_listener'

class RubyPropertyListener < RubyEventListener

  include_class java.beans.PropertyChangeListener
  include_class java.beans.PropertyChangeEvent


  def initialize( call_back_parent )
    super(call_back_parent)
  end

  def propertyChange(propertyChangeEvent)
    puts "IN propertyChangeEvent", propertyChangeEvent.inspect
    return if propertyChangeEvent.nil?

    callbacks = get_callbacks("#{propertyChangeEvent.getPropertyName}".to_sym)
    callbacks.each do |method|  
      if method.kind_of? Proc
        (0 == method.arity) ? method.call : method.call(propertyChangeEvent)
      else
        @parent.send(method, propertyChangeEvent)
      end
    end
  end
end