# Author::    Tom Statter & Andy Griffiths
# Copyright:: (c) Kubris 2008
# License::   MIT ?
#
require 'errors_controller'

class ComposerController < ApplicationController
  set_view  'ComposerView'
  set_model 'Composer'

  set_close_action :close

  def load(project, asset)
    @project = project
    model.asset = asset
    puts "START DIALOG MODEL : #{model.inspect}"
  end

  def add_new_composer_OK_action_performed

    update_model(view_state.first, :name)

    ctype = BasicType.multi_find_by_name( 'string', 'xsd' )

    model.create_composer_type( :klass => ctype )
    
    if(model.save)
      close
    else
      puts "SAVE ERRORS : #{model.errors.inspect}"
      dialog = ErrorsController.create_instance
      dialog.open(model)
    end
  end
   
  def add_new_composer_Cancel_action_performed
    close
  end  
end
