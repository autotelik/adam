class Property < ActiveRecord::Base
  
  # We expose an interface named element i.e contains polymorphic columns (element_id and element_type)
  #
  # Defines Type and ID of any ADAM object that has meta data
  # 
  belongs_to :element, :polymorphic => true
  
  belongs_to :system
  
end
