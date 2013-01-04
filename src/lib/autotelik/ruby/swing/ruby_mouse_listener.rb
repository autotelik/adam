# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     May 2009
# License::   MIT ?
#
# Usage :
#
require 'ruby_event_listener'

class RubyMouseListener < RubyEventListener
  java_import java.awt.event.MouseListener

  #interface = eval "java.awt.event.MouseListener"
  java.awt.event.MouseListener.java_class.java_instance_methods.each do |method|
    puts "INTERFACE REQUIRES METHOD #{method.name.underscore}"
  end

  def initialize( call_back_parent )
    super(call_back_parent)
  end

  def method_missing(method, *args, &block)
    event = args[0]
    return if event.nil?
    @parent.send( method.underscore, event ) if @parent.respond_to?(method.underscore)
  end

end