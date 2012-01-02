# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Jan 2009
# License::   MIT ?
#
# Adds behaviour to a parent

class RestrictionComposer < Composer

  # Note callbacks specified before associations to ensure entire calback Q is created/called

  before_create :ensure_name_on_create

  def ensure_name_on_create
    if(self.name.nil?)
      self.name = "(Restriction)"
    end
  end

end
