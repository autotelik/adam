require 'dialog_parent'

class ProjectView < DialogParentView
   
  set_java_class 'app.java.dialogs.ProjectDialog'
  
  map :view => "nameTextField.text", :model => :name
  map :view => "refTextField.text", :model => :identifier
  map :view => "descriptionTextArea.text", :model => :description
end