require 'dialog_parent'

class ComposerView < DialogParentView
   
  set_java_class 'app.java.dialogs.ComposerDialog'
  
  map :view => "nameTextField.text", :model => :name

end