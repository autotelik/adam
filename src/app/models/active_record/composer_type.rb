# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Dec 2008
# License::   MIT ?
#
class ComposerType < ActiveRecord::Base

  belongs_to  :composer

  # We expose an interface named klass i.e contains polymorphic columns (klass_id and klass_type)
  # Defines Class and ID for a Composer object, enabling a Composer's type to be anything,
  # such as another Composer, a basic type such as String or a type stored in 'Types' table 
  # 
  belongs_to :klass, :polymorphic => true
  
end
