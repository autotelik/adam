# Copyright:: (c) Kubris & Autotelik Media Ltd 2009
# Author ::   Tom Statter
# Date ::     May 2009
# License::   MIT ?
#
#             Base for nested Menus, added to the main application Menu

include_class javax.swing.JMenu
include_class javax.swing.JMenuItem

module MenuView 

  # Mixin the standard setup for a MenuView into the calling class
  def self.included(base)
    base.class_eval do
      set_java_class 'javax.swing.JMenu'

      define_signal :name => :load_menu,  :handler => :load_menu
    end
  end

  # THE SIGNATURE
  def load_menu( model, transfer )
    raise "Pure virtual - Must be implemented by derived class"
  end

end