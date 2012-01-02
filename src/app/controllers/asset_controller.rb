# Author::    Tom Statter & Andy Griffiths
# Copyright:: (c) Kubris 2008
# License::   MIT ?
#
require 'errors_controller'

class AssetController  < ApplicationController
  set_model 'Asset'
  set_view  'AssetView'

  set_close_action :close

  # Application must pass in selected external data we rely on - current project

  def load(project)
    #@project = project
    model.project = project
    puts "START DIALOG MODEL : #{model.inspect}"
  end
  
  def ok_button_action_performed
    puts "IN ASAssetControllerSET - ok_button_action_performed #{view_state.first}"

    update_model(view_state.first, :name)

    if(model.save)
      close
    else
      puts "SHOW ASSET ERRORS"
      dialog = ErrorsController.create_instance
      dialog.open(model)
    end
  end
 
  def cancel_button_action_performed
    close
  end  
end
