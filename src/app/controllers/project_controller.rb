# Author::    Tom Statter
# Copyright:: (c) Tom Statter for Autotelik Media 2011
#
# =>      May be used free of charge. Permission granted to reproduce for personal and educational use only.
# =>      Commercial copying, hiring, lending, selling is prohibited."
# =>      In all cases this notice must remain intact.
#
# License::   TBD - Open source but MIT
#
require 'errors_controller'

class ProjectController < ApplicationController
  set_view  'ProjectView'
  set_model 'Project'

  set_close_action :close

   def load(model)
    @main_model = model
  end

  def add_new_project_OK_action_performed

    update_model(view_state.first, :name, :identifier, :description)

    if(model.save)
      # force main model to load new project into list and make it current
      @main_model.load_projects(:name => model.name)
      close
    else
       puts "SAVE ERRORS : #{model.errors.inspect}"
      dialog = ErrorsController.create_instance
      dialog.open(model)
    end
  end
   
  def add_new_project_Cancel_action_performed
    close
    raise UserCanceledError.new("Nothing saved")
  end  
end
