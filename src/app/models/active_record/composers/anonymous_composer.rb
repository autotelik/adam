# A composer without a name. An anonymous grouping
require 'composer'

class AnonymousComposer < Composer

  # Note callbacks specified before associations to ensure entire calback Q is created/called

  before_create :ensure_name_on_create

  def ensure_name_on_create
    if(self.name.nil?)
      self.name = "(Anonymous)"
    end
  end

end
