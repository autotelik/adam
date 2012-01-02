# A base /class/mixin for dialog controllers opened and closed from main application
#
# N.B Every including class must include a status component that supports text called :
# 
#   dialogStatusTextArea
#
module DialogParentMixin  

  def self.included(view_class) 
    view_class.define_signal :name => :status,  :handler => :status 
    view_class.map :view => "dialogStatusTextArea.text", :model => :errors, :using => [:errors_to_text, nil]
  end 
end 

class DialogParentView < Monkeybars::View
 
  # update the status area with the result of ActiveRecord errors
  
  def status(model, transfer) 
    dialogStatusTextArea.text = errors_to_text(model.errors) if model.respond_to? :errors
  end 
  
  def errors_to_text(errors)
    s = String.new
    errors.each_full do |e|
      s << "#{e}\n"
    end
    s
  end 
  
end