# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
# The complete underlying structure can appear with cardinalty of n

class ListComposer < Composer

  # Note callbacks specified before associations to ensure entire calback Q is created/called

  before_create :ensure_name_on_create

  def ensure_name_on_create
    if(self.name.nil?)
      self.name = "(List)"
    end
  end

end
