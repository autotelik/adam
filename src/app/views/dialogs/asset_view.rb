require 'dialog_parent'

class AssetView < DialogParentView 
  set_java_class 'app.java.dialogs.AssetDialog'
  
  map :view => "nameTextField.text", :model => :name  
end