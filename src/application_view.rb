class ApplicationView < Monkeybars::View

  # Not found any docs on global signals .. don't think there's a 'monkeybars way', so do it in View base class.
  # signal map is keyed on view.class so cannot simply define a signal here and expect any controller
  # to be able to signal it ... must be explicitly set on each subclass
  def self.inherited(subclass)
    subclass.define_signal :name => :raise_simple_error, :handler => :simple_error_dialog
  end

  # Add content here that you want to be available to all the views in your application

  java_import javax.swing.JOptionPane

  def input_dialog( msg, title = "Input Dialog" )
    JOptionPane.showInputDialog(@main_view_component, msg, title, JOptionPane::QUESTION_MESSAGE)
  end


  def simple_error_dialog( model, transfer)
    message =  transfer[:error_message] || "Sorry, something unexpected went wrong"
    title   =  transfer[:error_title] || "Application Error"
    javax.swing.JOptionPane.show_message_dialog(nil, message, title, javax.swing.JOptionPane::DEFAULT_OPTION)
  end

  # Show a dialog asking the user to select a String:

  def choice_dialog( msg, choices, initial_selection, title = "Input Dialog" )
    oarray = choices.to_java
    JOptionPane.showInputDialog(@main_view_component, msg, title,
                                JOptionPane::QUESTION_MESSAGE, nil, oarray, oarray[initial_selection])
  end

  def to_combo_model(list)
    nodes = [*list]		# handles array of nodes or single node
    Java::javax.swing::DefaultComboBoxModel.new(nodes.to_java(:String))
  end

end