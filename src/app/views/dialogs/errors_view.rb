class ErrorsView < ApplicationView
  
  set_java_class "app.java.dialogs.ARErrorsDialog"

  #map :view => "errorsTextArea.text", :model => :errors, :using => [:errors_to_text, nil]

  # Enable the update of the errors directly from a supplied ActiveRecord model

  define_signal :name => :display, :handler => :display

  def display(model, transfer)
    puts transfer[:active_record].inspect
    errorsTextArea.text = errors_to_text(transfer[:active_record].errors) if transfer[:active_record].respond_to? :errors
  end
  
  def errors_to_text(errors)
    s = String.new
    errors.each do |a, e|
      s << "#{a} : #{e}\n"
    end
    s
  end
end