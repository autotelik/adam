# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
class ComposerMapping < ActiveRecord::Base
  belongs_to  :composer
  belongs_to  :mapping_schema
  belongs_to  :system_key_field
end
