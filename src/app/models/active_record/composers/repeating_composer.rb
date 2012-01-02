# Copyright:: (c) Kubris & Autotelik Media Ltd 2008
# Author ::   Tom Statter
# Date ::     Dec 2008
# License::   MIT ?
#
# A child node is of same type as parent, creating repeating tree of self

class RepeatingComposer < Composer

 # Note callbacks specified before associations to ensure entire calback Q is created/called

  before_create :ensure_name_on_create

  def ensure_name_on_create
    if(self.name.nil?)
      self.name = "(Repeating)"
    end
  end
end
