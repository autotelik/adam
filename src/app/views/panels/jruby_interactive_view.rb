# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     April 2009
# License::   MIT ?
#
require 'ruby_property_listener'

# Multiple IRB sessions can be started in the Document pane,
# so use this Iframe setup to represent a single irb session
require 'textpane_iframe'

include_class javax.swing.JLayeredPane
include_class javax.swing.GroupLayout


# Manage a set of irb sessions

class JRubyInteractiveView < ApplicationView

  set_java_class 'app.java.panels.JRubyInteractivePanel'

  include_class 'app.java.panels.JRubyInteractiveWorker'
  include_class java.awt.event.KeyEvent

  #  # The Sub View in which user can interact with a Calypso connection via JRuby
  #  #
  #  # ** Note ** :sub_view name (:conversion_tab) must match controller's add_nested_controller name
  #  # Need for stubs looks like MB bug, should be able to specify nil if no init code required
  #  nest :sub_view => :jruby_interactive, :using => [:stub1, :stub2]
  #
  #  def stub1(nested_view, nested_component, model, transfer)
  #  end
  #
  #  def stub2(nested_view, nested_component, model, transfer)
  #  end

  @@TAB_NAME = "JIRB Shell"

  def self.tab_name
    @@TAB_NAME
  end

  def load
    @frame_count = 0
    @xstart, @ystart = 10,10
    @workers = {}
    new_irb_frame
  end

  define_signal :name => :new,  :handler => :new

  def new(model, transfer)
    new_irb_frame
  end

  define_signal :name => :shutdown,  :handler => :shutdown

  def shutdown(model, transfer)
    @workers.each {|frm, w| w.getTar.shutdown() if w; frm.dispose }
  end

  # Only bother with updating our view/model if we are current Tab.

  define_signal :name => :workTabPane_state_changed,  :handler => :workTabPane_state_changed
 
  def workTabPane_state_changed(model, transfer) 
    if(transfer[:working_tab_name] == @@TAB_NAME)
    end
  end

  define_signal :name => :send_text,  :handler => :send_text

  # Append the supplied text to the session. transfer[:execute]

  def send_text(model, transfer)
    # irb is running in worker thread, so find teh currently active thread and process
    
    @worker = current_worker
    puts "IN send_text : #{@worker}"
    return unless @worker

    # Send the supplied jruby code to the process method of SwingWorker to push to jirb
    begin
      @worker.process([transfer[:text]]) if(transfer[:text])

      # If user has requsted the code is executed immeadiatly we need to mimic the user
      # hitting the Enter key as per jirb usage - sending '/r' or '\n\r' doesn't seem to work
      if(transfer[:execute])
        char = "\0"
        key_event = KeyEvent.new(@worker.getTextPane, KeyEvent::KEY_PRESSED, 0, 0, KeyEvent::VK_ENTER, char[0])
        @worker.getTar.keyPressed(key_event)
      end
    rescue => e
      puts e.backtrace
      puts "ERROR - Failed to process supplied text in jirb"
    end
  end

  def current_worker
    puts "IN current_worker : #{jriDesktopPane.getSelectedFrame}"
    puts @workers.inspect
    @workers[jriDesktopPane.getSelectedFrame]
  end

  # TODO - listen for closed frame events and decrement frame_count
  
  def new_irb_frame()
    @frame_count += 1
    begin
      jri_internal_frame = TextPaneIFrame.new(@xstart + (@frame_count * 10), @ystart + (@frame_count * 10))

      jriDesktopPane.add(jri_internal_frame, javax.swing.JLayeredPane::DEFAULT_LAYER)

      jriDesktopPane.setSelectedFrame(jri_internal_frame)

      worker = JRubyInteractiveWorker.new(jri_internal_frame.jri_text_pane)

      listener = RubyPropertyListener.new(self)

      worker.addPropertyChangeListener( listener )

      @workers[jri_internal_frame] = worker

      worker.execute()
    rescue => e
      puts "ERROR", e, e.backtrace
    end
  end

end