# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
require 'conversion_output_controller'
require 'conversion_controller'

class ConversionTabController < ApplicationController
  set_model 'ConversionTabModel'
  set_view  'ConversionTabView'
  
  set_close_action :close

  def load
    #puts "IN ConversionTabController : Creating nested controllers"
    # This is the sub view - pop up to edit or create conversions
    @conversion_controller = ConversionController.instance
    @conversion_controller.load
    #puts "add_nested_controller #{@conversion_controller}"
    # :name must match view's sub_view name i.e both must be :conversion_tab
    add_nested_controller(:conversion_tab, @conversion_controller)
    #puts "OUT ConversionTabController : load"
  end

  ##################
  # FORWARDED EVENTS (from main AdamController)
  ##################
 
  # User has clicked on or off our Tab, sync our model with current view,
  # and create transfer for all other data required from other controller
  #
  def workTabPane_state_changed( main_model )
    if(main_model.working_tab_index == ConversionTabView.tab_name)
      
      transfer[:working_tab_index] = main_model.working_tab_index   # Set details from Main controller
      transfer[:working_tab_name]  = main_model.working_tab_name
      transfer[:asset]             = main_model.asset
   
      signal :workTabPane_state_changed

      update_model(view_state.model, :run_buttons)

      # Each row has set of buttons, assign actionPerformed listener on the buttons
      model.run_buttons.each_with_index do |b,i|

        # Single listener, with multiple callbacks, individually identifed by the ActionCommand

        listener ||= RubyActionListener.new( self )

        callback_key = "#{b.getText}#{i}_button_action_performed"

        puts "ADD RUN BUTTON #{callback_key}"

        b.setActionCommand(callback_key)
        b.addActionListener(listener)

        listener.add_callback_method( callback_key, :action_run_conversion)# do |event|
        # run_conversion( event)
        # end

        #al = ActionListener.new()
        #def al.actionPerformed(e) puts "we are here hello world" end
        #b.addActionListener( al )
      end
    end
  end

  # Handle Mouse events within the Table.
  # Actions depends on click count and column
  #
  def conversionsJXTable_mouse_clicked(event)
    update_model(view_state.model, :nodes, :selected_node)
    
    puts "IN conversionsJXTable_mouse_clicked : #{event.inspect}"
    #puts "MOUSE #{event.class} : #{event.getClickCount} : BUTTON #{event.getButton}"

    # Double Click => EDIT
    if(event.getClickCount == 2)
      edit
      
    elsif( event.getButton == java.awt.event.MouseEvent::BUTTON3)
      
      transfer[:event] = event

      listener = PopupActionListener.new( self )

      items = ["Run", "Edit", "Delete", "View Mapping"]

      listener.add_callback_method("Edit",   :edit)

      listener.add_callback("Delete") do
          model.delete_current_node
      end

      listener.add_callback("Run") do
        clear_view_state

        update_model(view_state.model, :nodes, :selected_node)
        data = model.run_current_conversion

        #puts "IN CONVERSIONS DATA #{data}"
        if data
          out = ConversionOutputController.instance
          out.open(data)
        end
      end

      listener.add_callback("View Mapping") do
        puts "VIEW MAPPING ASSOCIATED WITH CONVERSION"
      end

      pmenu = PopupMenuController.create_instance

      pmenu.open(event, items, listener )
    end
  end

  def edit()
    puts "IN ConversionTabController - edit #{model.inspect}"
    if model.current_node
      # Call the nested controller to pop up edit pane
      @conversion_controller.edit(model.current_node)
      @conversion_controller.show()
    end
  end


  def delete()
    puts "IN ConversionTabController - delete #{model.inspect}"
    if model.current_node
      # Call the nested controller to pop up edit pane
      model.destroy
      update_view
    end
  end


  # user clicks on the create new conversion button - launch popup nested view
  
  def conversions_create_button_action_performed(event)
    puts "IN ConversionTabController : create_button_action_performed #{event}"
    @conversion_controller.create
    @conversion_controller.show()

    # TODO - only update if something actually saved
    signal :populate
    
  end

  def action_run_conversion(event)
    puts "IN CAllBACK - #{view_state.inspect} #{event}"
    # view_state gets cached between MB event handlers,
    # as we aren't in a MB generated event handler, we have to make sure we clear out cache first,
    # to ensure we get current state of the view
    clear_view_state    #
    
    update_model(view_state.model, :nodes, :selected_node)
    data = model.run_current_conversion

    #puts "IN CONVERSIONS DATA #{data}"
    if data
      out = ConversionOutputController.instance
      out.open(data)
    end
  end
end