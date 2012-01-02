require 'dialog_parent'

class FromExcelView < DialogParentView
  
  include DialogParentMixin
    
  set_java_class 'FromExcelDialog'
  
 # map :view => "nameTextField.text", :model => :name
  #map :view => "refTextField.text", :model => :identifier
  #map :view => "descriptionTextArea.text", :model => :description
    
  define_signal :name => :errors,  :handler => :errors
  

  def load
    #if @@signal_mappings[ProjectView]
    #  @@signal_mappings[ProjectView].merge!( @@signal_mappings[DialogParentView] ) 
  #  else
  #   @@signal_mappings[ProjectView] = @@signal_mappings[DialogParentView] 
  #  end
  end

end