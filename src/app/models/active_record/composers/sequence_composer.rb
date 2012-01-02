# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Nov 2008
# License::   MIT ?
#
# Details::   Requires the elements in the group to appear in the specified sequence within the containing element.

class SequenceComposer < Composer

  # Note callbacks specified before associations to ensure entire calback Q is created/called

  before_create :ensure_name_on_create

  def ensure_name_on_create
    if(self.name.nil?)
      self.name = "(Sequence)"
    end
  end
  
end
