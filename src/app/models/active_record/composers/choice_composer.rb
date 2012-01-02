# Only one of our children or child nodes can appear in any particular output view

class ChoiceComposer < Composer

  # Note callbacks specified before associations to ensure entire calback Q is created/called

  before_create :ensure_name_on_create

  def ensure_name_on_create
    if(self.name.nil?)
      self.name = "(Choice)"
    end
  end

end
